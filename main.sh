#! /bin/bash

echo -e "\nА-05-19 Ушаков Н.А. Вариант 24"
echo -e "Лабораторная работа 6\n"

# Проверяет запись числа в виде триад
is_triads() {
    local cs=$1
    local flag=true
    if [[ ${#cs} -lt 3 ]]; then 
        flag=false
    else 
        for (( i=0; i < ${#cs}-3; i+=4 ))
        do
            if [[ "${cs:$i+3:1}" != " " ]]; then
                if [[ "${cs:$i:1}" != "." ]]; then
                    flag=false
                else 
                    ((i+=2))
                fi
            fi
        done
    fi
    echo $flag
}

# Алгоритм перевода из 2-8 в 10 сс
_binoct_to_dec() {
    local cs=$1
    local sep=`expr index "$cs" .`
    if [[ $sep -ne 0 ]]
    then 
        local frac=${cs:$sep}
        local whole=${cs:0:$sep-1}
        local fr=0; local pow=0.5
        for (( i=0, len=${#frac}; i < $len; i++ ))
        do
            if [[ "${frac:$i:1}" == "1" ]]
            then fr=$(echo "scale=$len; $fr+$pow" | bc)
            fi
            pow=$(echo "scale=$len; $pow/2.0" | bc)
        done
    else 
        whole=$cs
    fi
    frac=${fr%%0*0}
    local out=$((2#$whole))$frac
    echo $out
}

# Перевод произвольных чисел из 2-8 в 10 сс
binoct_to_dec() {
    local cs=$1
    local sign="${cs:0:1}"
    if [[ "$sign" == "-" ]]; then 
        if [[ "${cs:1:1}" == " " ]]; then 
            cs=${cs:2}     
        else 
            cs=${cs:1}
        fi
    fi
    cs=${cs// /}
    local out=$(_binoct_to_dec $cs)
    if [[ "$sign" == "-" ]]; then 
        out="-"$out   
    fi
    echo $out
}

# Перевод произвольных чисел из 10 в 2-10 сс
dec_to_bindec() {
    local cs=$1
    for (( i=0; i < ${#cs}; i++ )); do
        case ${cs:i:1} in 
            "-" ) out+="- ";;
            "0" ) out+="0000 ";;
            "1" ) out+="0001 ";;
            "2" ) out+="0010 ";;
            "3" ) out+="0011 ";;
            "4" ) out+="0100 ";;
            "5" ) out+="0101 ";;
            "6" ) out+="0110 ";;
            "7" ) out+="0111 ";;
            "8" ) out+="1000 ";;
            "9" ) out+="1001 ";;
            "." ) out+=". ";;
            *   ) out="error"
        esac
    done
    echo $out  
}

# Проверяет число на валидность
is_valid_value() {
    local cs=$1
    if [[ "${cs:0:1}" == "-" ]]; then 
        if [[ "${cs:1:1}" == " " ]]; then 
            cs=${cs:2}     
        else 
            cs=${cs:1}
        fi
    fi
    if [[ `expr index "$cs" -` != 0 ]]; then
        local flag=false
    fi 
    flag=$(is_triads $cs)
    if [[ "$flag" == "true" ]]; then
        cs=${cs// /}; cs=${cs/./};
        for (( i=0; i < ${#cs}; i++ )); do
            case ${cs:i:1} in 
                "0" ) ;;
                "1" ) ;;
                *   ) flag=false;;
            esac
        done
    fi
    echo $flag
}

# Перевод числа из 2-8 в 2-10 сс
# Присутствует валидация данных
binoct_to_bindec() {
    if [[ "$1" == "-d" ]]; then
        local debug=$1; shift
    elif [[ "$1" == "" ]]; then
        shift
    fi
    local num=$1
    echo -e "Исходные данные:\t"$num
    local valid=$(is_valid_value "$num")
    if [[ "$valid" == "true" ]]; then
        local buff=$(binoct_to_dec "$num")
        local out=$(dec_to_bindec "$buff")
        if [[ "$debug" == "-d" ]]; then
            echo -e "В 10-ой сс:\t\t"$buff
        fi
    else
        out="Ошибка: Некорректные данные"
    fi
    echo -e "Результат:\t\t"$out"\n"
}


# Точка старта скрипта

# Получение данных из консоли
binoct_to_bindec "$1" "$2"
# Первый параметр - отладка


# Передача данных внутри скрипта
<<TEST
binoct_to_bindec "$1" "101 . 110 110"
binoct_to_bindec "$1" "-101 011.110 000 " 
binoct_to_bindec "$1" "- 010 001 110 . 000 001" 
binoct_to_bindec "$1" "110 . 000" 
binoct_to_bindec "$1" "011" 
binoct_to_bindec "$1" "..." 
binoct_to_bindec "$1" "1010 001 000" 
binoct_to_bindec "$1" "-100 1-0 010" 
binoct_to_bindec "$1" "1.0 010 01." 
binoct_to_bindec "$1" "12345" 
binoct_to_bindec "$1" "110 001 123 . 000"
TEST




# Вызовы для отладки
<<TEMP 
"101 110 . 110"
is_valid_value "101 110"
is_triads "101 110 001 011"
dec_to_bindec "-123.654"
binoct_to_dec "-100 . 001"
binoct_to_bindec "101 . 110 110"
TEMP