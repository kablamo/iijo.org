package CatalystX::FlashCards::User;
use Moose::Role;
use feature qw/say/;

use Data::Dumper::Concise;
use FlashCards::Model::User;


has '_user' => (
   is  => "rw",
);


sub user {
   my $self = shift;
   my $user = shift;

   # set
   if (defined $user) {
      $self->_user($user);
      $self->_setAuthenCookie($user->userId);
      $self->stash->{user} = $user;
      return $user;
   }

   # get
   if (defined $self->_user) {
      $user = $self->_user;
   }
   else {
      $user = $self->_getUserFromConfigFile;
      $user = $self->_getUserFromAuthenCookie  if !defined $user;
      $user = $self->_createNewUser            if !defined $user;
   }
   $self->_user($user);
   $self->stash->{user} = $user;
   return $user;
}

sub _setAuthenCookie {
   my $self = shift or die;
   my $userId = shift or die;

   my %expires;
   %expires = (expires => '+1y') if $self->req()->param('remember');
   $self->set_authen_cookie(value => {userId => $userId}, %expires);

   return;
}

sub _getUserFromConfigFile {
   my $self = shift;

   return unless (defined $self->config->{user} and 
                  defined $self->config->{user}->{userId});

   my $userId = $self->config->{user}->{userId};
   return FlashCards::Model::User->new(userId => $userId);
}

sub _getUserFromAuthenCookie {   
   my $self = shift or die;
   my $cookie = $self->authen_cookie_value();
   return unless $cookie && $cookie->{userId};
   return FlashCards::Model::User->new(userId => $cookie->{userId});
}

sub _createNewUser {
   my $self = shift;
   my $guest = 'y';
   my $username;

   if (!defined $self->req->param('username')) {
      my $random   = Fey::Literal::Function->new('randomblob', 16);
      my $hex      = Fey::Literal::Function->new('hex', $random);
      my $default  = Fey::Literal::Function->new('lower', $hex);
      $username = $default;
   }
   else {
      $guest    = 'n';
      $username = $self->req->param('username');
      my $duplicateUser = FlashCards::Model::User->new(username => $username);
      Catalyst::Exception->throw('That username is already taken')
         if defined $duplicateUser;
   }

   my $user = FlashCards::Model::User->insert(
      username => $username,
      guest    => $guest
   );
   
   $self->_setAuthenCookie($user->userId);

   return $user;
}

1;
