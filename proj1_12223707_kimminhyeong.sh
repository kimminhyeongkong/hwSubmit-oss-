#!/bin/bash
echo -e " --------------------------
User Name: kim min hyeong
Student Number: 12223707
[ MENU ]
1. Get the data of the movie identified by a specific
'movie id' from 'u.item'
2. Get the data of action genre movies from 'u.item’
3. Get the average 'rating’ of the movie identified by
specific 'movie id' from 'u.data’
4. Delete the ‘IMDb URL’ from ‘u.item
5. Get the data about users from 'u.user’
6. Modify the format of 'release date' in 'u.item’
7. Get the data of movies rated by a specific 'user id'
from 'u.data'
8. Get the average 'rating' of movies rated by users with
'age' between 20 and 29 and 'occupation' as 'programmer'
9. Exit
-------------------------"
state="go"
until [ $state = "stop" ]
do
        read -p "Enter your choice [ 1 - 9 ] " num
        case $num in
        1)
                read -p "Please enter 'movie id' (1~1682):" movId
                awk -F "|" -v movId="$movId" '$1 == movId' u.item
                ;;
	2)
                echo "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n): "
                read user_input

                if [ "$user_input" = "y" ]; then
                        awk -F "|" '$7 == 1 {print $1, $2}' u.item | head -n 10
                fi
                ;;
        3)
                read -p "Please enter 'movie id' (1~1682):" movId
                sum=0
                count=0
                echo "average rating of $movId: $(awk -F '\t' -v movId="$movId" '$2 == movId { sum += $3; count++ } END { if (count > 0) print sum / count }' u.data)"
                ;;
        4)

                echo "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n)"
                read user_input

                if [ "$user_input" = "y" ]; then
                        sed 's/http[^|]*//g' u.item |head -n 10
                fi
                ;;
	5)
                echo "Do you want to get the data about users from ‘u.user’?(y/n)"
                read user_input

                if [ "$user_input" = "y" ]; then
                        sed 's/|[^|]*$//' u.user | sed 's/^/user /' |sed 's/|/ is /' |sed 's/|/ years old /'|sed 's/\M[^|]*/Male/;s/\F[^|]*/Female/'|sed 's/|/ /'|head -n 10
                fi
                ;;

        6)
                echo "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n)"
                read user_input

                if [ "$user_input" = "y" ]; then
                        sed 's/\([0-9]\{2\}\)-Jan-\([0-9]\{4\}\)/\201\1/;s/\([0-9]\{2\}\)-Feb-\([0-9]\{4\}\)/\202\1/;s/\([0-9]\{2\}\)-Mar-\([0-9]\{4\}\)/\203\1/;s/\([0-9]\{2\}\)-Mar-\([0-9]\{4\}\)/\203\1/;s/\([0-9]\{2\}\)-Apr-\([0-9]\{4\}\)/\204\1/;s/\([0-9]\{2\}\)-May-\([0-9]\{4\}\)/\205\1/;s/\([0-9]\{2\}\)-Jun-\([0-9]\{4\}\)/\206\1/;s/\([0-9]\{2\}\)-Jul-\([0-9]\{4\}\)/\207\1/;s/\([0-9]\{2\}\)-Aug-\([0-9]\{4\}\)/\208\1/;s/\([0-9]\{2\}\)-Sep-\([0-9]\{4\}\)/\209\1/;s/\([0-9]\{2\}\)-Oct-\([0-9]\{4\}\)/\210\1/;s/\([0-9]\{2\}\)-Nov-\([0-9]\{4\}\)/\211\1/;s/\([0-9]\{2\}\)-Dec-\([0-9]\{4\}\)/\212\1/' u.item | tail -10
                fi
                ;;
	7)
                read -p "Please enter 'user id' (1~943):" userId
                awk -F '\t' -v userId="$userId" '$1 == userId {print $2}' u.data | sort -n | tr '\n' '|'
                echo -e "\n"
                awk -F '\t' -v userId="$userId" '$1 == userId {print $2}' u.data | sort -n | head -n 10 | while read movieId; do
                  awk -F '|' -v movId="$movieId" '$1 == movId {print $1"|"$2}' u.item
                done
                ;;
        8)
                awk -F '|' '$4 == "programmer" && $2 >= 20 && $2 <= 29 {print $1}' u.user > selected_users.txt
                awk -F '\t' 'FNR==NR { selected_users[$1] = 1; next } $1 in selected_users {print $2, $3}' selected_users.txt u.data > selected_ratings.txt
                awk '{
                movie_id = $1
                rating = $2
                movie_ratings[movie_id] += rating
                movie_counts[movie_id]++
                }
                END {
                for (movie_id in movie_ratings) {
                avg_rating = movie_ratings[movie_id] / movie_counts[movie_id]
                rounded_avg_rating = sprintf("%.5f", avg_rating)
                printf("%d %s\n", movie_id, rounded_avg_rating)
                }
                }
                ' selected_ratings.txt
                ;;
	9)
                echo "Bye!"
                state="stop"
                ;;
        esac
done
