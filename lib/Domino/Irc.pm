###
# Copyright (c) 2016 Rolando González Chévere <rolosworld@gmail.com>
#
# This file is part of Domino.
#
# Domino is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3
# as published by the Free Software Foundation.
#
# Domino is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Meta.  If not, see <http://www.gnu.org/licenses/>.
####
package Domino::Irc;
use Modern::Perl;
use Time::HiRes;

use parent "Bot::BasicBot";

use Domino::Game::Irc;
use Domino::Game::Irc::Commands::Status;
use Domino::Game::Irc::Commands::Bots;
use Domino::Game::Irc::Commands::Join;
use Domino::Game::Irc::Commands::Play;

=pod

This module is expected to:
- Connect into an IRC server
- Receive the messages from the server
- Parse the messages into commands
- Proxy the commands into the IRC game
- Respond

=cut

sub initCommands {
    my ($self) = @_;
    $$self{command}{status} = Domino::Game::Irc::Commands::Status->new;
    $$self{command}{bots} = Domino::Game::Irc::Commands::Bots->new;
    $$self{command}{join} = Domino::Game::Irc::Commands::Join->new;
    $$self{command}{play} = Domino::Game::Irc::Commands::Play->new;
}

sub initGame {
    my ($self, $args) = @_;
    if ($args) {
	$$self{game_conf} = $args;
    }
    $$self{game} = Domino::Game::Irc->new($$self{game_conf});
}

sub parseCommand {
    my ($self, $msg) = @_;
    if ($msg && substr($msg,0,1) eq '!') {
	my $command = substr($msg,1);
	$command =~ s/ +/ /g;

	my @parts = split(' ', $command);
	if (scalar(@parts) > 0) {
	    if ($$self{command}{$parts[0]}) {
		return $$self{command}{$parts[0]}->parse(@parts);
	    }
	}
    }
    return undef;
}

sub said {
    my ($self, $args) = @_;

    if (ref($self) eq 'Domino::Irc::Bot') {
	printf("%s: %s\n", $$args{who}, $$args{body});
    }

    my $command = $self->parseCommand( $$args{body} );
    if (!$command) {
	return undef;
    }

    my $results = $command->run($self, $args);
    if ($results) {
	$self->sayResults( $results );
    }

    my $game = $$self{game};
    my $table = $$game{table};
    if ($table && defined $$table{current_player}) {
	# handle bot players
	my $current_player = $$table{players}[$$table{current_player}];
	while ($table && ref($current_player) eq 'Domino::Player::Bot') {
	    $results = $game->run( {
		who => $$current_player{name},
		channel => $$args{channel}
	    },{
		player => $current_player
	    } );
	    if ($results) {
		$self->sayResults( $results );
	    }

	    $table = $$game{table};
	    if ($table) {
		$current_player = $$table{players}[$$table{current_player}];
	    }
	}
    }

    if (!$$self{game}{table}) {
	$self->initGame;
    }

    return undef;
}

sub sayResults {
    my ($self, $results) = @_;
    foreach my $result ( @$results ) {
	$self->say( $result );
	if (ref($self) eq 'Domino::Irc::Bot') {
	    Time::HiRes::sleep(1.5); # Twitch limit
	}
    }
}

1;
