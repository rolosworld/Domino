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
package Domino::Irc::FakeBot;
use Modern::Perl;

use parent 'Domino::Irc';

=pod

This module is expected to:
- Connect into an IRC server
- Receive the messages from the server
- Parse the messages into commands
- Proxy the commands into the IRC game
- Respond

=cut

sub new {
    my ($class, $args) = @_;
    return bless $args || {}, $class;
}

sub say {
    my ($self, $s) = @_;
    if ($$s{who}) {
	printf("%s: %s\n", $$s{who}, $$s{body});
    }
    else {
	printf("%s\n", $$s{body});
    }
}

sub run {
    my $self = shift;
    while (1) {
	printf '(who:body): ';
	my $say = <STDIN>;
	if (!$say) {
	    next;
	}

	my @said = split(':', $say);
	if (scalar(@said) != 2 ) {
	    next;
	}

	my $msg = $self->said({
	    who => $said[0],
	    body => $said[1]
	});
	if ($msg) {
	    printf( "%s\n", $msg);
	}
    }
}

1;
