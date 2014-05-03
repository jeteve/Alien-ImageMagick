use 5.006;
use strict;
use warnings;
use Alien::Base::ModuleBuild;

use Config;

my $perlbin = $Config{perlpath};
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
    },
    requires => {
        'perl' => 5.006,
        'Alien::Base' => 0,
    },
    add_to_cleanup      => [ 'Alien-ImageMagick-*' ],

    alien_name => 'MagickWand',
    # alien_repository => {
    #     protocol => 'http',
    #     host => 'www.imagemagick.org',
    #     location => '/download/',
    #     exact_filename => 'ImageMagick.tar.gz'
    # },
    alien_repository => {
                         protocol => 'local',
                         location => 'inc',
                         exact_filename => 'ImageMagick.tar.gz',
                        },
    alien_build_commands => [
       'LDFLAGS='.$LDFLAGS.' %pconfigure --prefix=%s --with-perl='.$perlbin.' --enable-shared '.$use_threads ,
       'make'
    ],
    alien_install_commands => [
        'LDFLAGS='.$LDFLAGS.' make install'
    ]
);

$builder->create_build_script();
