#!/bin/bash
#Please do not shoot the pianist. He is doing his best 

STAND=$1
DESCR=$2
report=$STAND.$DESCR

if [ "$DESCR" == '' ];
then
{
        echo -e "\n\nUSAGE:\n";
        echo "Backup:";
        echo -e " $0 <StandID> <BackupID>\n";
        echo "List stand backups:";
        echo -e " $0 <ANYreport.file> list\n"
        echo "Remove ALL stand backups:"
        echo -e " $0 <ANYreport.file> kill\n"
        echo "Start/Stop/Restore:";
        echo -e " $0 <ANYreport.file> start|stop|restore\n";
        exit 1;
};
fi
if [ "$DESCR" == 'list' ];
then
{
        echo "BACKUPS:"
	cat ./$STAND |awk '{print$5}' |sed 's/\..//g' | while read line; do prlctl backup-list |grep $line ;done
	echo "Done.";
        exit 0;
};
fi
if [ "$DESCR" == 'kill' ];
then
{
        echo "REMOVING BACKUPS..."
        cat ./$STAND | awk '{print$5}' |sed 's/\..//g' | while read bkup; do prlctl backup-delete -t $bkup;done
        echo "Done.";
	rm $STAND
        exit 0;
};
fi
if [ "$DESCR" == 'stop' ];
then
{
        echo "Stopping stand..."
        cat ./$STAND | awk '{print$3}' | while read s; do prlctl stop $s --kill;done
        echo "Done.";
        exit 0;
};
fi
if [ "$DESCR" == 'start' ];
then
{
        echo "Starting stand..."
        cat ./$STAND | awk '{print$3}' | while read s; do prlctl start $s;done
        echo "Done.";
        exit 0;
};
fi
if [ "$DESCR" == 'restore' ];
then
{
        echo "Restoring..."
        cat ./$STAND | while read s; do $s;done
        echo "Done.";
        exit 0;
};
fi

vzlist -a |grep $STAND |awk '{print$1}' |while read line; do prlctl backup $line;done | sed -E "s/\bBa\w+ .{10}/prlctl restore /g;/backup hdd/d;s/\bTh\w+ .{49}/-t/g;s/[.\t]*$//;s/\n//g;/full/d;" | xargs -L 2 >> ./$report
echo "CT backup done. VM backup started..."
prlctl list -a |grep $STAND |awk '{print$1}' |while read line; do prlctl backup $line;done | sed -E "s/\bBa\w+ .{10}/prlctl restore /g;/backup hdd/d;s/\bTh\w+ .{49}/-t/g;s/[.\t]*$//;s/\n//g;/full/d;" |xargs -L 2 >> ./$report
cat ./$report ; echo "Done."
exit
