use 5.006;
use strict;
use warnings;
use Alien::Base::ModuleBuild;

use Config;

my $perlbin = $Config{perlpath};
my $perlversion = $Config{version};
my $core_lib =  $Config{archlib}.'/CORE/';
my $use_threads = $Config{usethreads} ? '' : '--without-threads';
my $LDFLAGS= '-L'.$core_lib;

my $builder = Alien::Base::ModuleBuild->new(
    module_name         => 'Alien::ImageMagick',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome.eteve@gmail.com>},
    dist_version_from   => 'lib/Alien/ImageMagick.pm',
    configure_requires => {
        'Alien::Base' => 0,
        'Module::Build' => 0.38,
    },
    build_requires => {
        'Test::More' => 0,
        'Alien::Base' => 0,
    },
    requires => {
        'perl' => 5.006,
        'Alien::Base' => 0,
    },
    add_to_cleanup      => [ 'Alien-ImageMagick-*' ],

    alien_name => 'MagickWand',
    alien_repository => {
        protocol => 'http',
        host => 'www.imagemagick.org',
        location => '/download/',
        exact_filename => 'ImageMagick.tar.gz'
    },
    ## For development, to save the download time,
    ## download the package once and put it in an 'inc' directory.
    # alien_repository => {
    #                      protocol => 'local',
    #                      location => 'inc',
    #                      exact_filename => 'ImageMagick.tar.gz',
    #                     },
    alien_build_commands => [
       'LDFLAGS='.$LDFLAGS.' %pconfigure --prefix=%s --with-perl='.$perlbin.' --enable-shared '.$use_threads ,
       'make'
    ],
    alien_install_commands => [
        'LDFLAGS='.$LDFLAGS.' make install', # This will build the included PerlMagick package.
        $perlbin.' -e "use Image::Magick; print Image::Magick->QuantumDepth"', # This checks Image magick is there fine.
    ]
);

# Current perl config args.
my $config_args = $Config{config_args};

unless( $builder->config('useshrplib') eq 'true' ){
  die qq|

*******************************************************************
**
** Sorry, you cannot configure this with this Perl installation. **
**
**
** PLEASE READ THIS:
**
** Image Magic requires perl to be compiles with -Duseshrplib, but this perl
** ($perlbin) is not compiled with it.
**
** This is because Image Magick Perl integration package (PerlMagick , providing Image::Magick)
** can only compile with libperl.so, not libperl.a.
**
** See http://www.imagemagick.org/discourse-server/viewtopic.php?f=7&t=25526
**
** -> If you are using a System Perl, this should be be alright,
** as they are usually compiled with -Duseshrplib. So if you see this,
** check with your distribution.
**
** -> Perlbrew users should re-install their perl like that:
**
** perlbrew --force install $perlversion $config_args -Duseshrplib
**
*******************************************************************

|;


}

$builder->create_build_script();
