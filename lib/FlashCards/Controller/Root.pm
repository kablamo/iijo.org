package FlashCards::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use Captcha::reCAPTCHA;
use Sys::Hostname;

__PACKAGE__->config(namespace => '');

sub index : Private {
   my ($self, $c, $page) = @_; 
   $page = 0 
      if !defined $page;

   $c->user->userId;
   if ($c->user->guest eq 'n') {
      $c->response->redirect("/mysets");
      $c->detach();
   }

   my @sets = FlashCards::Model::SetOfCards->selectAll(page => $page)->all;

   $c->stash->{morePages} = 1
      if $c->config->{pageSize} == scalar(@sets);
   $c->stash->{page} = $page;
   $c->stash->{sets} = \@sets;
   $c->stash->{template} = 'index.tt';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body('404: page not found.  Return to <a href="/">IIJO.org</a>.');
    $c->response->status(404);
}

sub about : Local {}
sub tools : Local {}
sub faq   : Local {}

sub slugify : Private {
   my ($self, $c, $url) = @_; 
   $url =~ s/[^a-zA-Z0-9 -]//g;
   $url = lc($url);
   $url =~ s/\s+/-/g;
   $c->stash->{slug} = $url;
}

sub getReCaptchaHtml : Private {
   my ($self, $c) = @_;
   my $publicKey = FlashCards->config->{recaptcha}->{publicKey};
   my $rc = Captcha::reCAPTCHA->new;
   $c->stash->{'recaptcha'} = $rc->get_html($publicKey);
}

sub checkReCaptchaResponse : Private {
   my ($self, $c) = @_;

   # validate
   Catalyst::Exception->throw("the recaptcha_challenge_field is empty")
      unless defined $c->req->params->{recaptcha_challenge_field};
   Catalyst::Exception->throw("the recaptcha_response_field is empty")
      unless defined $c->req->params->{recaptcha_response_field};

   my $privateKey = FlashCards->config->{recaptcha}->{privateKey};
   my $rc         = Captcha::reCAPTCHA->new;
   my $result     = $rc->check_answer(
         $privateKey, 
         $c->req->address,
         $c->req->params->{recaptcha_challenge_field},
         $c->req->params->{recaptcha_response_field},
   );

   if ($result eq 'HASH' && exists $result->{is_valid}) {
      $c->stash->{recaptchaOk} = 1;
      $c->stash->{recaptchaError} = $result->{error} 
         if ref $result eq 'HASH';
      return 1;
   }

   $c->stash->{message} = "You might be a robot.  You didn't pass the reCAPTCHA test.  Try again.";
   $c->stash->{recaptchaOk} = 0;
   return 0;
}

sub updateCard : Private {
   my ($self, $c, $correct) = @_;

   my $card = $c->stash->{card};
   delete $c->stash->{card};

   my $delayExponent = $card->delayExponent;
   $delayExponent += 1 if $correct;
   $delayExponent -= 1 if (!$correct && $delayExponent > 1);

   if ($delayExponent > 0) {
      my $minutes  = 4 ** $delayExponent;
      my $nextDate = Fey::Literal::Function->new('datetime', 'now', "+$minutes minutes");
      my $lastDate = Fey::Literal::Function->new('datetime', 'now');

      $card->update(
         delayExponent => $delayExponent,
         nextDate      => $nextDate,
         lastDate      => $lastDate,
      );
$c->log->info("====== updated difficulty.  cardId: " . $c->stash->{cardId} . ", delayExponent: $delayExponent, minutes: $minutes");
   }
}

sub begin : Private {
   my ($self, $c) = @_;
   FlashCards::Model::Schema->ClearObjectCaches();
   $c->stash->{hostname} = hostname;
}

sub end : ActionClass('RenderView') {
    my $self = shift;
    my $c    = shift;

    if (scalar @{ $c->error } && ${$c->error()}[0] !~ /Caught exception/i) {
       $c->stash->{errors}   = $c->error;
       $c->stash->{template} = 'error.tt';
       $c->forward('FlashCards::View::TT');
       $c->error(0);
    }

    $c->response->content_type('text/html; charset=utf-8')
       unless $c->response->content_type;
    $c->response->header('Cache-Control' => 'no-cache');
}

__PACKAGE__->meta->make_immutable;

1;
