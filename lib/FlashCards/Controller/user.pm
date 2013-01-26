package FlashCards::Controller::user;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Authen::Passphrase::BlowfishCrypt;
use Data::TreeDumper;
use Fey::DBIManager;
use FlashCards::Model::User;
use URI::Escape qw/uri_escape/;
#use LWPx::ParanoidAgent;
#use Net::OpenID::Consumer;
#use WWW::Facebook::API;

#our $API_KEY    = "650f21530149f58ea7314240cbb5f38b";
#our $APP_SECRET = "d7d1a0bc9d6a8989d2c95b130823829c";

=head1 NAME

FlashCards::Controller::user - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut


sub login : Local {
   my ($self, $c) = @_; 
}

sub loginSubmit : Local {
   my ($self, $c) = @_; 
   my $username = $c->req->param('username');
   my $password = $c->req->param('password');

   Catalyst::Exception->throw('<b>username</b> is a required field')
      unless defined $username;
   Catalyst::Exception->throw('<b>password</b> is a required field')
      unless defined $password;

   my $user = FlashCards::Model::User->new(username => $username) or
      Catalyst::Exception->throw("The username <b>$username</b> doesn't exist");
    
   $user->password->match($password) 
      ? $c->user($user)
      : Catalyst::Exception->throw('your username or password is wrong');

   $c->response->redirect('/mysets');
}

sub register : Local {
   my ($self, $c) = @_; 
}

sub create : Local {
   my ($self, $c) = @_; 

   Catalyst::Exception->throw('<b>username</b> is a required field')
      if !defined $c->req->param("username");
   Catalyst::Exception->throw('<b>password</b> is a required field')
      if !defined $c->req->param("password");
   Catalyst::Exception->throw('<b>email</b> is a required field')
      if !defined $c->req->param("email");

   my $blowfish = Authen::Passphrase::BlowfishCrypt->new(
      passphrase  => $c->req->param('password'),
      salt_random => 1,
      cost        => 12,
   );
   $c->user->update(
      username => $c->req->param("username"),
      password => $blowfish,
      email    => $c->req->param("email"),
      guest    => "n",
      slug     => $c->slugify($c->req->param("username")),
   );

   $c->response->redirect('/mysets/0/newuser');
}

sub logout : Local {
   my ($self, $c) = @_;
   my $apiKey    = $c->config->{facebook}->{apiKey};
   my $appSecret = $c->config->{facebook}->{appSecret};

   $c->unset_authen_cookie();

   $c->_user(undef);

   $c->res->redirect("/user/login");
}  

sub user : Chained('/') CaptureArgs(1) {
   my ($self, $c, $userId) = @_; 
   $c->stash->{userId} = $userId;
}

sub view : Path('/user') Args {
   my ($self, $c, $userId, $username) = @_; 

   $c->user->userId;

   my $user = FlashCards::Model::User->new(userId => $userId);
   Catalyst::Exception->throw('no user with userId: $userId')
      unless defined $user;
   
   $c->stash->{profile}   = $user;
   $c->stash->{template}  = 'user/profile.tt';
   $c->forward('/mysets/statbar');
}

sub password : Local {
   my ($self, $c) = @_; 

   my $user = $c->user;
   Catalyst::Exception->throw('please create an account to enable this functionality')
      if $user->guest eq 'y';

   $c->stash->{profile} = $user;
}

sub passwordSubmit : Local {
   my ($self, $c) = @_; 
   my $user     = $c->user;
   my $username = uri_escape($user->username);
   my $userId   = $user->userId;

   my $blowfish = Authen::Passphrase::BlowfishCrypt->new(
      passphrase  => $c->req->param('password'),
      salt_random => 1,
      cost        => 12,
   );
   $c->user->update(password => $blowfish);
   $c->stash->{profile} = $user;
   $c->response->redirect("/user/$userId/$username");
}

sub username : Local {
   my ($self, $c) = @_; 

   my $user = $c->user;
   Catalyst::Exception->throw('no user with userId: $userId')
      unless defined $user;

   Catalyst::Exception->throw('Hey knock it off.  You can only change your own username.')
      unless $user->userId eq $c->user->userId;
   
   $c->stash->{profile} = $user;
}

sub usernameSubmit : Local {
   my ($self, $c) = @_;
   my $user     = $c->user;
   my $username = uri_escape($user->username);
   my $userId   = $user->userId;

   $c->user->update(username => $c->req->param("username"));
   $c->stash->{profile} = $c->user;
   $username = uri_escape($username);
   $c->response->redirect("/user/$userId/$username");
}


=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
