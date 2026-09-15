# Fallacy
An esolang made within ~1 day
Operates token by token, as opposed to line by line

This is a rather simple esolang, only having 16 keywords
I'll keep it brief
def - Defines a variable based on the provided argument
init - Initializes a variable based on the provided argument
chk0 - Checks if the provided var is 0, if true, set the zero flag to true, otherwise false
chkdef - Ditto, but checks if the provided argument is also the name of a variable and instead sets the "defined" flag
ify - If the last check was false, jump to the next endbl
ifn - If the last check was true, jump to the next endb
getusrinput - Gets a single user input
markln - Marks that token as a jump place, with a provided argument as an identifier
jmp - Jumps to either another token or a defined marker
end - Exclusive to the out command, tells the interpreter when to stop when outing
out - Prints a variable, you can also slide in "ascii" to make it print out those characters in ascii
endbl - Ends an ify or ifn block, go figure
addvar - Obvious
subvar - Obvious
startscr - Starts the script at that token, required
endscr - Ends the script at that token, required
This language sucks, please do not write Fallacy DOOM in it or I will personally fuMarkln you

have fun i guess lol
