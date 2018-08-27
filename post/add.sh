#!/bin/bash
# FileName: post/add.sh
#
# Author: rachpt@126.com
# Version: 2.2v
# Date: 2018-07-28
#
#-------------settings----------------#

torrent2add="${download_url}&passkey=${passkey}"

#-------------functions---------------#
function set_ratio()
{
    for oneTorrentID in `"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -l|grep %| awk '{print $1}'|sed 's/\*//g'|sort -nr`
    do
	    oneTorrent=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep Name|awk '{print $2}'`
	    
	    set_commit_hust=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'hudbt.hust.edu.cn'`
	    set_commit_whu=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'whupt'`
	    set_commit_npupt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'npupt.com'`
	    set_commit_nanyangpt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.nanyangpt.com'`
	    set_commit_byrbt=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.byr.cn'`
	    set_commit_cmct=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.hdcmct.org'`
	    #---add new site's seed ratio here---#
	    #set_commit_new=`"$trans_remote" ${HOST}:${PORT} --auth ${USER}:${PASSWORD} -t $oneTorrentID -i |grep 'tracker.new.com'
	    	    
        if [ "$TR_TORRENT_NAME" = "$oneTorrent" ]; then
        
            if [ -n "$set_commit_hust" ]; then
		        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_hudbt
                break
            elif [ -n "$set_commit_whu" ]; then
		        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_whu
                break
            elif [ -n "$set_commit_npupt" ]; then
		        "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_npupt
                break
            elif [ -n "$set_commit_nanyangpt" ]; then
                sleep 1
	    	    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_nanyangpt
	    	    sleep 4
	    	    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_nanyangpt
	    	    break
	        elif [ -n "$set_commit_byrbt" ]; then
	            "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_byrbt
	            break
	        elif [ -n "$set_commit_cmct" ]; then
	            "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_cmct
	            break	            
	        #---add new site's seed ratio here---#
	        #elif [ -n "$set_commit_new" ]; then
	        #   "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} -t $oneTorrentID -sr $ratio_new
	        #   break
            fi
        fi
    done
}

#------------add torrent--------------#
function add_torrent_special_for_whupt()
{
    http -d "$torrent2add" -o "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent"
    transmission-edit -r 'http://' 'https://' "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent"

    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent" -w "$TR_TORRENT_DIR"
    #---set seed ratio---#
    set_ratio
    echo "+++++++++++++[added]+++++++++++++" >> "$log_Path"
    rm -f "${AUTO_ROOT_PATH}/tmp/${t_id}.torrent"
}

#------------add torrent--------------#
function add_torrent_to_TR()
{
    "$trans_remote" ${HOST}:${PORT} -n ${USER}:${PASSWORD} --add "$torrent2add" -w "$TR_TORRENT_DIR"
    #---set seed ratio---#
    set_ratio
    echo "+++++++++++++[added]+++++++++++++" >> "$log_Path"
}
#-----------call function-------------#
if [ "$torrent2add" ]; then
    if [ "$postUrl" = 'https://whu.pt/takeupload.php' ]; then
        add_torrent_special_for_whupt
    else
        add_torrent_to_TR
    fi
fi
