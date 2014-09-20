use 5.006;
use strict;
use warnings;
use Alien::Base::ModuleBuild;

use Config;

my $perlbin = $Config{perlpath};
my $perlversion = $Config{version};
my $siteprefix = $Config{siteprefix};

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
                             ## This siteprefix will install the execs in perl's /bin and the libs in perl's lib/
                             'LDFLAGS='.$LDFLAGS.' %pconfigure --prefix=%s --exec-prefix='.$siteprefix.' --with-perl='.$perlbin.' --enable-shared '.$use_threads ,

                             # Patch the PerlMagick makefiles to reflect lib installation places.
                             # This is because ImageMagic's PerlMagick package comes with Makefile.PL files
                             # containing a relative reference to the build directory ../magick/.libs
                             #
                             # This causes https://rt.cpan.org/Public/Bug/Display.html?id=98979
                             #
                             # This (fairly) dirty patch will hopefully solve the issue,
                             # only until Image magick decides to change their Perl distribution structure.

                             # See original source in  http://trac.imagemagick.org/browser/ImageMagick/trunk/PerlMagick/Makefile.PL
                             # if this breaks.
                             q|echo "Patching Makefile.PL files in `pwd`. See |.__FILE__.q| for more"|,
                             q|perl -pi -e 's:-L\.\./magick(.*?)/\.libs:-L|.$siteprefix.q|/lib:gi' PerlMagick/Makefile.PL|,
                             q|perl -pi -e 's:-L\.\./\.\./magick(.*?)/\.libs:-L|.$siteprefix.q|/lib:gi' PerlMagick/quantum/Makefile.PL|,
                             q|perl -pi -e 's:-L\.\./\.\./magick(.*?)/\.libs:-L|.$siteprefix.q|/lib:gi' PerlMagick/default/Makefile.PL|,
                             ,
                             'make',
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
** Image Magic requires perl to be built with -Duseshrplib, but this perl
** ($perlbin) is not built with it.
**
** This is because Image Magick Perl integration package (PerlMagick , providing Image::Magick)
** can only be linked against libperl.so, not libperl.a.
**
** See http://www.imagemagick.org/discourse-server/viewtopic.php?f=7&t=25526
**
** -> If you are using a System Perl, this should be just fine,
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
