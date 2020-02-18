#!/bin/bash
#Name of container file

user_password=''
mkdir "Database"
function check_for_file(){
	#This function checks if the storing file exists, if not creates one.
	#Required variables	
	current_directory=$(pwd)
	file_address="$current_directory/Database/"
	#if [ -e "Database" ]
	#then
		#If file created, does nothing.
	#	clear
	#else
		#Create the file
		#mkdir "Database"
		cd $(pwd)/Database
		touch name.txt
		echo $USER >> name.txt
		zip -P $user_password secure.zip name.txt
		rm name.txt
	#fi
}

#Normally,we don't need to use a main function.But using a main function has some advantages.
#By this way, depending on the user input, program can start itself recursively
function main(){
clear
dialog --title "Journal" --backtitle "A program to keep track of your diaries" --yesno \ "Welcome to Journal, $USER.Click yes if you want to create a new journal.You can show your previous journals  by clicking no.Press ESC to exit." 10 50

main_response=$?
case $main_response in
   0) 
	DIALOG=${DIALOG=dialog}	
	diary_date=`$DIALOG --stdout --title "CALENDAR" --calendar "Please choose a date to save  		a new diary" 0 0 7 7 2019`
	
	calendar_response=$?
	case $calendar_response in
		0)
		 #inputbox works differently,so it's requires more effort to store the value of it.
		 #At the end of the line, stdin, stdout and stderr handled by redirecting
		 user_input=$(dialog --inputbox "Input text for $diary_date" 20 40 3>&1 1>&2 2>&3 3>&-)
		 inputbox_response=$?
		 case $inputbox_response in
			 0)
			  #That's not a secure way to have passwords becase we pass the password as a 	      parameter but we already got the password
			  clear
			  user_password=$(dialog --title "Password" --clear --insecure --passwordbox "Enter 			  your password" 20 40 3>&1 1>&2 2>&3 3>&-)	 
			  password_response=$?
			  case $password_response in
				  0)
					#Creates a text file, checks if the storing file exists
					#Some parts didn't work use I commented a way that program can run
					#unzipping the file, modify it then zip it again with the 			   password				
					parsed_name=$(echo "$diary_date" | sed -r 's/\//_/g')
					text_file_name="${USER}:${parsed_name}.txt"
					
 					check_for_file
					touch $text_file_name 					
					echo $user_input >> $text_file_name	
				 	zip -ur -P $user_password "secure.zip" $text_file_name
					rm $text_file_name
					main				    
				  ;;
				  1)
					main
				  ;;
			  esac 
			 ;;
			 1)
			  main
			 ;;
		 esac
		;;
		1)
		 main
		;;
	esac	

   ;;
   1) 
	DIALOG=${DIALOG=dialog}
	tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
	trap "rm -f $tempfile" 0 1 2 5 15

	function choose_file(){
	rm *.txt
 	unzip --qP $user_password secure.zip 
	FILE=`$DIALOG --stdout --title "Press space button to choose a file" --fselect $(pwd)/ 14 48`

	case $? in
		0)
		
			$DIALOG --title "TEXT" --textbox $FILE 20 90
			choose_file
	;;
		1)
			main ;;
		255)
			main ;;
	esac


	}

	pass_correct=""
	while [ "$pass_correct" != "true" ]
	do
	$DIALOG --title "Please enter your password" --clear \
		--insecure \
        	--passwordbox "Password": 16 51 2> $tempfile

	retval=$?
	input=$(cat $tempfile)
	case $retval in
  	0)
		if [ "$input" ==  "$user_password" ]; then
		pass_correct="true"
		choose_file
		fi ;;
	
  	1)
   	 main ;;
 	 255)
   	 main
    	;;
	esac
	done ;;
   255) 
		echo "Program terminated." 
   		exit;;
esac
}
main


