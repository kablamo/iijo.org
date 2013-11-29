# Moose stuff
requires 'Moose';
requires 'MooseX::Params::Validate';
requires 'MooseX::ClassAttribute';

# Plack stuff
requires 'Plack';
requires 'Plack::Middleware::Deflater';
requires 'Plack::Middleware::AccessLog::Timed';
requires 'Plack::Middleware::Assets';

# Catalyst stuff
requires 'Catalyst';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::TT';
requires 'Catalyst::Plugin::Assets';
requires 'Catalyst::Plugin::Cache::HTTP';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Log::Dispatch';
requires 'Catalyst::Plugin::StackTrace';
requires 'CatalystX::AuthenCookie';

# database stuff
requires 'DBD::SQLite';
requires 'DBI';
requires 'Fey';
requires 'Fey::Loader';
requires 'Fey::ORM';

# random web stuff
requires 'Authen::Passphrase';
requires 'CEDict::Pinyin';
requires 'Config::General';
requires 'HTML::Scrubber';
requires 'Math::Random::MT';
requires 'Time::HiRes';
requires 'URI::Escape';

# random stuff
requires 'DateTime';
requires 'JSON';
requires 'JSON::XS';
requires 'List::MoreUtils';
requires 'Log::Dispatch';
requires 'Log::Dispatch::Config';
requires 'Path::Class';

# testing
requires 'Data::Printer';
requires 'Test::Most';

# vim: set ft=perl
