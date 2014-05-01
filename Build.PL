use 5.006;
use strict;
use warnings;
use Alien::Base::ModuleBuild;

use Config;

my $perlbin = $Config{perlpath};
my $core_lib;
( $core_lib ) =  (  $Config{ccdlflags}  =~ m/([^\,]+\/CORE)/  );
my $use_threads = $Config{usethreads} ? '' : '--without-threads';
my $LDFLAGS= [ '-L'.$core_lib ];

my $builder = Alien::Base::ModuleBuild->new(
    module_name         => 'Alien::ImageMagick',
    license             => 'perl',
    dist_author         => q{Jerome Eteve <jerome.eteve@gmail.com>},
    dist_version_from   => 'lib/Alien/ImageMagick.pm',
    configure_requires => {
        'Alien::Base' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'Alien-ImageMagick-*' ],
    create_makefile_pl => 'traditional',

    alien_name => 'MagickWand',
    alien_repository => {
        protocol => 'http',
        host => 'www.imagemagick.org',
        location => '/download/',
        exact_filename => 'ImageMagick.tar.gz'
    },
    extra_linker_flags => $LDFLAGS,
    alien_build_commands => [
       '%pconfigure --prefix=%s --with-perl='.$perlbin.' --enable-shared '.$use_threads ,
       'make'
    ],
);

$builder->create_build_script();
