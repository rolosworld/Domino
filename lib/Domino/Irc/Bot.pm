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
package Domino::Irc::Bot;
use Modern::Perl;

use parent "Domino::Irc";

=pod
You'll be passed a hashref that contains the arguments described below. Feel free to alter the values of this hash - it won't be used later on.

who
    Who said it (the nick that said it)

raw_nick
    The raw IRC nick string of the person who said it. Only really useful if you want more security for some reason.

channel
    The channel in which they said it. Has special value "msg" if it was in a message. Actually, you can send a message to many channels at once in the IRC spec, but no-one actually does this so this is just the first one in the list.

body
    The body of the message (i.e. the actual text)

address
    The text that indicates how we were addressed. Contains the string "msg" for private messages, otherwise contains the string off the text that was stripped off the front of the message if we were addressed, e.g. "Nick: ". Obviously this can be simply checked for truth if you just want to know if you were addressed or not.

    You should return what you want to say. This can either be a simple string (which will be sent back to whoever was talking to you as a message or in public depending on how they were talking) or a hashref that contains values that are compatible with say (just changing the body and returning the structure you were passed works very well.)

    Returning undef will cause nothing to be said.
=cut

1;
