    #!/bin/bash

    main() {
    clear
    files=($(ls *.csv)) 
    num_files=$(ls *.csv | wc -l)
    runningTopTempTotal=0
    runningBottomTempTotal=0
    runningTopPressTotal=0
    runningBottomPressTotal=0
    topTempHigh=0;
    topTempLow=99999;
    bottomTempHigh=0;
    bottomTempLow=99999;
    topPressHigh=0;
    topPressLow=999999;
    bottomPressHigh=0;
    bottomPressLow=999999;
    outFile='./out.csv'
    echo "name,date,maxTopTemp,maxTopPress,maxBottomTemp,maxBottomPress,averageTemp,averagePress"

    }

numCompare() {
  # awk -v n1="$1" -v n2="$2" 'BEGIN {printf "%s " (n1<n2?"<":">=") " %s\n", n1, n2}'
  if awk -v n1="$1" -v n2="$2" 'BEGIN { exit (n1 <= n2) }' /dev/null; then echo 1; else echo 0; fi
}


function processFiles() {
  for filename in "${files[@]}"
    do
        declare -a INDICIES=("top-temp" "bottom-temp" "top-press" "bottom-press" "date")
        for index in "${INDICIES[@]}"
        do
            let a=$(awk -F',' '/'$index'/ {
                for (f = 0; f <= NF; ++f) {
                    if ($f == "'$index'") {
                        print f
                    }
                }
            }' $filename)

        if [ "$index" == "top-temp" ];
        then

           val=$(numCompare $topTemp $topTempHigh)

            if [ "$val" == 1 ];
            then            
                topTempHigh=$topTemp
            fi
           val=$(numCompare $topTemp $topTempLow)

            if [ "$val" == 0 ];
            then            
                topTempLow=$topTemp
            fi
            topTemp=$(tail +2  test.csv  | cut -d "," -f$a)
            runningTopTempTotal=$(echo "scale=3;($runningTopTempTotal+$topTemp)" | bc)

        elif [ "$index" == "bottom-temp" ]; then

           val=$(numCompare $bottomTemp $bottomTempHigh)

            if [ "$val" == 1 ];
            then            
                bottomTempHigh=$bottomTemp
            fi
           val=$(numCompare $bottomTemp $bottomTempLow)

            if [ "$val" == 0 ];
            then            
                bottomTempLow=$bottomTemp
            fi
             bottomTemp=$(tail +2 $filename | cut -d "," -f$a)
            runningBottomTempTotal=$(echo "scale=3;($runningBottomTempTotal+$bottomTemp)" | bc)
        elif [ "$index" == "top-press" ]; then

           val=$(numCompare $topPress $topPressHigh)

            if [ "$val" == 1 ];
            then            
                topPressHigh=$topPress
            fi
           val=$(numCompare $topPress $topPressLow)

            if [ "$val" == 0 ];
            then            
                topPressLow=$topPress 
            fi
            topPress=$(tail +2 $filename | cut -d "," -f$a)      
            runningTopPressTotal=$(echo "scale=3; ($topPress + $runningTopPressTotal)" | bc)     
        elif [ "$index" == "bottom-press" ]; then
           val=$(numCompare $bottomPress $bottomPressHigh)

            if [ "$val" == 1 ];
            then            
                bottomPressHigh=$bottomPress
            fi
           val=$(numCompare $bottomPress $bottomPressLow)

            if [ "$val" == 0 ];
            then             
                bottomPressLow=$bottomPress
            fi
            bottomPress=$(tail +2 $filename | cut -d "," -f$a)
             runningBottomPressTotal=$(echo "scale=3; ($bottomPress + $runningBottomPressTotal)" | bc)     
        elif [ "$index" == "date" ]; then  
            thisDate=$(tail +2 $filename | cut -d "," -f$a)
        fi
        done
        averageTemp=$(echo "scale=3;($topTemp+$bottomTemp)/2" | bc)
        averagePress=$(echo "scale=3;($topPress+$bottomPress)/2" | bc)
        echo "$filename,$thisDate,$topTemp,$topPress,$bottomTemp,$bottomPress,$averageTemp,$averagePress"   

    done
    
}



printResults() {
    echo 
    echo "Top Temp High | Top Temp Low | Bottom Temp High | Bottom Temp Low " 
    echo "----------------------------------------------------------------------------"
    echo "$topTempHigh , $topTempLow , $bottomPressHigh, $bottomPressLow"


    echo 
    echo
    topTempAvg=$(echo "scale=3; ($runningTopTempTotal / $num_files)" | bc)     
    bottomTempAvg=$(echo "scale=3; ($runningBottomTempTotal / $num_files)" | bc)     
    topPressAvg=$(echo "scale=3; ($runningTopPressTotal / $num_files)" | bc)  
    bottomPressAvg=$(echo "scale=3; ($runningBottomPressTotal / $num_files)" | bc)        

    echo "Top Temp Avg | Bottom Temp Avg | Top Press Avg | Bottom Press Avg"
    echo "----------------------------------------------------------------------------"
    echo "$topTempAvg, $bottomTempAvg, $topPressAvg, $bottomPressAvg "
}


main
processFiles
printResults