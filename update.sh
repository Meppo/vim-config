#!/bin/bash
if [ $# -lt 2 ]; then
	echo "too few arguments!"
	echo "Usage: ./update.sh [option] [program_path]"
	echo "options:"
	echo -e "\t -a  add program"
	echo -e "\t -d  del program"
	exit 1
fi

while getopts a:d: opt  
do  
 case $opt in  
 a)  add_program=$OPTARG;;
 d)  del_program=$OPTARG;;
 *) echo $opt not a option;;  
 esac  
done  
echo -e "\nAdd $add_program, Del $del_program ...\n"

UpdateParam()
{
	if [ ! -n "$1" ];then
		echo "No program, exit."
		exit 0
	fi

    if [ ! -d "$1" ];then
		echo "$1 is not exist or not a directory, exit!"
		exit 1
    fi

	PLUGIN_DIR="$HOME/.rd"
	PROGRAM_FULL_NAME=`cd $1; pwd`
	PROGRAM_BASE_NAME=`basename $1`
    TAGS_FATHER_DIR="/home/vim_tags_dir"
	TAGS_DIR="$TAGS_FATHER_DIR/$PROGRAM_BASE_NAME"
	VIM_CONFIG="$HOME/.vimrc"
	PROGLIST="$PLUGIN_DIR/.proglist"
	TMP_FILE_LIST=
}

ErrorExit()
{
	error_no=${1:-1}
	rm -rf $TAGS_DIR
	exit $error_no
}

CheckDir()
{
	dir=$1
	echo "Begin to Check the directory $dir"
	
	if [ ! -e $dir ] ; then
		echo "Not exist the $dir, begin to create!"
		mkdir -p "$dir"
	else
		if [ ! -d $dir ] ; then
				echo "Exist a file have the same name $dir, Create direcotry failed... Exit!"
				return 0
		fi
	
		echo "Have the directory  $dir, begin to clean and add new tags, Do you want to clean?[y]"
		read res
		res=${res:-"y"}
		
		if [ "$res" = "y" ] || [ "$res" = "yes" ]; then
			echo "clean $dir"
			rm -rf $dir/*
		else
			echo "Exist the same $dir not access to clean...Exit!"
			return 1
		fi
	fi
	
	if [ $? -eq 0 ]; then
		echo "Check the directory $dir success!"
		return 0
	else
		echo "Check the directory $dir failed... Exit!"
		return 1
	fi
}

MatchStr()
{
    isFound=0
    echo "$1" | grep -q "$2"
    if [ $? -eq 0 ]; then
       isFound=1
    fi
    echo $isFound
}

GetFindFilter ()
{
    local program="$1"
    local match_res=0

    if [ ! -n "$program" ];then
        return 0
    fi

    match_res=`MatchStr $program "N360_"`
    if [ $match_res -eq 1 ];then
        echo "\\( -path '*/path_1*' -a \\( -path '*/want_path_under_path1*' -name '*.[ch]' -print -o -true \\) \\)\
 -o -path  '*/no/need/path/*' -prune \
 -o -path '*/.svn' -prune \
 -o -name '*.[ch]'"
        return 0
    fi

    echo "-name '*.[ch]'"
    return 0;
}

CreateFileList()
{
	local tmp_file_list=/tmp/$$.list
	echo "Now create the file list for $PROGRAM_BASE_NAME"

    eval find $PROGRAM_FULL_NAME `GetFindFilter $PROGRAM_BASE_NAME` -print > $tmp_file_list
	if [ -e $tmp_file_list ];then
		TMP_FILE_LIST=$tmp_file_list
		return 0
	else
		return 1
	fi
}

CreateTags()
{
	echo "Now create the tags according file_list[$TMP_FILE_LIST] and mv to $TAGS_DIR...."
	ctags -R --fields=+lS -L $TMP_FILE_LIST && mv tags $TAGS_DIR &
	return 0
}

CreateCsope()
{
	echo "Now create the cscope according file_list[$TMP_FILE_LIST] and mv to $TAGS_DIR...."
	cscope -Rbqk -i $TMP_FILE_LIST && mv cscope.* $TAGS_DIR/  &
	return 0
}

UpdateVimrc()
{
	if [ ! -e $PROGLIST ];then
		touch $PROGLIST
	fi
	exist=`cat $PROGLIST | grep "^$PROGRAM_FULL_NAME$"`
	if [ "$1" == "add" ];then
		if [ "$exist" == "" ];then
			echo "$PROGRAM_FULL_NAME" >> $PROGLIST
		fi
	elif [ "$1" == "del" ]; then
		if [ "$exist" != "" ];then
			sed -i "\\#^$PROGRAM_FULL_NAME\$#d" $PROGLIST
		fi
	else
		echo "just update .vimrc"
	fi

	#get all program basename
	projects_path_list=($(cat $PROGLIST))
	num=${#projects_path_list[@]}
	for ((i=0; i<num; i++))
	do
		project_name[$i]=$(basename ${projects_path_list[$i]})
	done

	#sort basename
	for ((i=0; i<num; i++))
	do
		len1=${#project_name[i]}
		for ((j=i+1; j<num; j++))
		do
			len2=${#project_name[$j]}
			if [ $len1 -lt $len2 ];then
				tmp=${project_name[$i]}
				project_name[$i]=${project_name[$j]}
				project_name[$j]=$tmp

				tmp=${projects_path_list[$i]}
				projects_path_list[$i]=${projects_path_list[$j]}
				projects_path_list[$j]=$tmp
			fi
			
		done
	done

	#begin to replace .vimrc
	tmp_vim_config=/tmp/.vimrc

	#replace project list
	sed -n '0, /__PROJECTLIST_SED_BEGIN__/p' $VIM_CONFIG > $tmp_vim_config

	echo "            let project_dicts = {" >> $tmp_vim_config
	for ((i=0; i<num; i++))
	do
        echo -e "                \\'${project_name[$i]}': '${projects_path_list[$i]}'," >> $tmp_vim_config
    done
	echo -e "            \\}" >> $tmp_vim_config

	#add FILE_TAG_END to end
	sed -n '/__PROJECTLIST_SED_END__/,$p' $VIM_CONFIG >> $tmp_vim_config

	#replace config file
	mv $tmp_vim_config $VIM_CONFIG
}

DelProgram()
{
	echo -e "\nWill del program $1 ..."
	#update param
	UpdateParam $1

	#del all tag
	rm -rf $TAGS_DIR

	#update .vimrc
	UpdateVimrc del
	if [ $? -ne 0 ]; then
		ErrorExit 7
	fi
}

#del program
if [ -n "$del_program" ];then
	DelProgram $del_program
fi

#add program
if [ ! -n "$add_program" ];then
	echo "have no program to add, exit."
	exit 0
fi
echo -e "\nWill add $add_program ..."

UpdateParam $add_program

CheckDir $TAGS_DIR
if [ $? -ne 0 ]; then
	ErrorExit 2
fi

echo "Begin to create \"ctags\" , \"cscope\" of [$PROGRAM_BASE_NAME]"
CreateFileList
if [ $? -ne 0 ]; then
	ErrorExit 3
fi

CreateTags
if [ $? -ne 0 ]; then
	ErrorExit 4
fi

CreateCsope
if [ $? -ne 0 ]; then
	ErrorExit 5
fi

UpdateVimrc add
if [ $? -ne 0 ]; then
	ErrorExit 7
fi
echo "^_^  Completed! Please wait all process done then into the $PROGRAM_FULL_NAME and vim the Programe with this plugins!"
