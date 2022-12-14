!/bin/env bash
#
#BashCards, a flashcard app in pure bash
#

trap 'REDRAW' WINCH

VERSION="v0.1"

GET_TERM() {
	read -r LINES COLUMNS < <(stty size)
}

REDRAW() {
	GET_TERM
	SETUP_TERM
	SETUP_UI
	DRAW_QUESTION
}

SETUP_TERM() {
	printf '\e[?1049h'
	printf '\e[2J\e[H'
	printf '\e[?25l'
}

RESTORE_TERM() {
	printf '\e[?25h'
	printf '\e[?1049l'
}


SETUP_UI() {
	PRINT_PROG
	PRINT_VER
	PRINT_FILE
	PRINT_NUMBER
}

PRINT_PROG() {
#Program name, top left
	printf '\e[H'
	printf "BASHCARDS"
}

PRINT_VER() {
#Version, top right
	printf '\e[0;'$COLUMNS'H'
	printf '\e['${#VERSION}'D'
	printf "$VERSION"
}

PRINT_FILE() {
#Filename, bottom left
	printf '\e['$LINES';0H'
	printf "$FILENAME"
}

PRINT_NUMBER() {
#Number, bottom, right
	NUMBERS="$CURRENT_OPTION"/"$FILELINES"
	printf '\e['$LINES';'$COLUMNS'H'
	printf '\e['${#NUMBERS}'D'
	printf "$NUMBERS"
}

SETUP_BCTF() {
	FILELINES=$(wc -l $FILENAME | cut -d ' ' -f1)
}

DRAW_QUESTION() {
	HALF_LINE=$(($LINES / 2))
	HALF_COLUMN=$(($COLUMNS / 2))
	printf '\e['$HALF_LINE';'$HALF_COLUMN'H'
	printf '\e[2K'
	QUES_TEXT=$(cat "$FILENAME" | sed -n "$CURRENT_OPTION"p "$FILENAME" )
	printf '\e['$(( ${#QUES_TEXT} / 2))'D'
	echo $QUES_TEXT
}

Q_INCREASE() {
	if [[ $CURRENT_OPTION -lt $FILELINES ]]
	then
		((CURRENT_OPTION=CURRENT_OPTION+1))
	fi
}

Q_DECREASE() {
	if [[ $CURRENT_OPTION -le 1 ]]
	then
		CURRENT_OPTION=1
	fi
	if [[ $CURRENT_OPTION -gt 1 ]]
	then
		((CURRENT_OPTION=CURRENT_OPTION-1))
	fi
}


INPUT() {
	escape_char=$(printf "\u1b")
	read -rsn1 mode # get 1 character
	if [[ $mode == $escape_char ]]; then
		read -rsn2 mode # read 2 more chars
	fi
	case $mode in
		'[A') Q_DECREASE ;;
		'[B') Q_INCREASE ;;
		'[D') Q_DECREASE ;;
		'[C') Q_INCREASE ;;
		'q') RESTORE_TERM && exit ;;
		*) echo 'brokey' ;;
	esac
}


#
#Main
#

#startup variables
FILENAME=$1
CURRENT_OPTION=1
QUESTION=true

if [[ $FILENAME == "" ]];
then
	echo "Please supply a text file"
	exit
fi

GET_TERM
SETUP_TERM


SETUP_BCTF
SETUP_UI
while true
do
	PRINT_NUMBER
	DRAW_QUESTION
	INPUT
done
