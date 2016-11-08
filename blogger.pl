#!/usr/bin/perl

use strict;
use warnings;

use REST::Client;
use JSON::XS;
use Data::Dumper;
use MIME::Base64;
use File::Slurp;
use File::Find::utf8;
use FindBin qw($Bin);

use Readonly;
Readonly::Scalar my $CLIENT_ID
    => '431571614658-72jvnsoi4jeu8e5t3tt67jlodp7k58fn.apps.googleusercontent.com';
Readonly::Scalar my $CLIENT_SEC => 'ezZHWiVYfS9vq3ON6IYzuKN6';
Readonly::Scalar my $BLOG_ID    => '7678772071518232421';
Readonly::Scalar my $HTML_PATH  => "$Bin/_build/html/documentation";

use utf8;
binmode(STDOUT,':utf8');

my $token = $ARGV[0];
if ( !defined($token) ) {
    my $client = REST::Client->new();
    $client->setHost('https://accounts.google.com');
    $client->POST(
        'o/oauth2/v2/auth?'
        . 'scope=https://www.googleapis.com/auth/blogger&'
        . 'redirect_uri=http://localhost:8080&'
        . 'response_type=code&'
        . "client_id=$CLIENT_ID"
    );
    my $path = $client->responseHeader('Location');
    system( 'google-chrome', $path );
    print "Process authorization and paste code here\n";

    my $code = readline(STDIN);
    chomp($code);

    $client->setHost('https://www.googleapis.com');
    $client->POST(
        '/oauth2/v4/token?'
        . "code=4/$code&"
        . "client_id=$CLIENT_ID&"
        . 'redirect_uri=http://localhost:8080&'
        . 'grant_type=authorization_code&'
        . "client_secret=$CLIENT_SEC"
    );
    my $response = decode_json($client->responseContent());

    $token = $response->{'access_token'};
}

my $client = REST::Client->new();
$client->setHost('https://www.googleapis.com');

my $pages = {};
my $response = get_pages( $client, $token );
print_ids($response, $pages );

my $next_token = $response->{'nextPageToken'};
while ( defined($next_token) ) {
    $response = get_pages( $client, $token, $next_token );
    print_ids($response, $pages );
    $next_token = $response->{'nextPageToken'};
}

my @files;
find (
    sub {
        if ( -f $File::Find::name && $File::Find::name =~ /blog_.+\.html/ ) {
            push @files, $File::Find::name;
        }
    },
    $HTML_PATH
);

foreach my $file ( @files ) {
    print "\nProcessing $file\n";
    my $content = read_file( $file, { binmode => ':utf8' } );
    $file =~ s/^.+blog_(.+)\.html$/$1/;
    my $body = {
        'content' => $content,
        'title'   => $file,
        'url'     => 'https://dnd-wod.blogspot.com/p/blog_' . $file . '.html'
    };

    my $page_id = $pages->{$file};
    if ( defined($page_id) ) {
        $client->PUT(
            "blogger/v3/blogs/$BLOG_ID/pages/$page_id?access_token=$token",
            encode_json($body),
            {'Content-Type' => 'application/json','Accept' => 'application/json'}
        );
        if ( $client->responseCode() eq '200' ) {
            print sprintf("Page: <%s> id: <%s> was succesfully updated\n", $file, $page_id );
        }
        else {
            print sprintf( "Error <%s> occured during processing of Page: <%s> id: <%s>\n",
                $client->responseContent(),
                $file,
                $page_id
            );
        }
    }
    else {
        $client->POST(
            "blogger/v3/blogs/$BLOG_ID/pages?access_token=$token",
            encode_json($body),
            {'Content-Type' => 'application/json','Accept' => 'application/json'}
        );
        if ( $client->responseCode() eq '200' ) {
            print sprintf("Page: <%s> was succesfully added\n", $file);
        }
        else {
            print sprintf( "Error <%s> occured during processing of Page: <%s>\n",
                $client->responseContent(),
                $file,
            );
        }
    }
}

print "TOKEN = <$token>\n";

sub print_ids {
    my ($response, $pages) = @_;

    foreach my $page ( @{ $response->{'items'} } ) {
        print sprintf( "Page with name:<%s>, ID:<%s>\n",
            $page->{'title'},
            $page->{'id'}
        );
        $pages->{$page->{'title'}} = $page->{'id'};
    }

    return ;
}

sub get_pages {
    my ( $client, $access_token, $next_token ) = @_;

    my $query = "blogger/v3/blogs/$BLOG_ID/pages?access_token=$access_token"
            . '&fetchBodies=false'
            . '&fields=items,nextPageToken'
    ;
    if ( defined($next_token) ) {
        $query .= "&pageToken=$next_token";
    }

    $client->GET( $query );
    if ($client->responseCode() ne '200') {
        print "Error\n";
        print "Responce code: " . $client->responseCode() . "\n";
        print "Responce body: " . $client->responseContent() . "\n";
    }
    
    return decode_json($client->responseContent());
}
