#!/bin/sh

# Autor: César Voginski <cesarvog@cesarvog.dev>
# Output to dwm bar with bitcon clock ram and etc. 

dte() {
		echo -e "$(date +%d.%m) 🕒 $(date +%H:%M)"
}

calc(){ awk "BEGIN { print "$*" }"; }
fmtmoney() {
	r=$1
	r=$(calc $r/1000)
	r=$(echo "$r" | rev | cut -c3- | rev)
	r="$r K"
	echo -e $r
}

cpu(){
		read cpu a b c previdle rest < /proc/stat
	 	prevtotal=$((a+b+c+previdle))
		sleep 0.5
		read cpu a b c idle rest < /proc/stat
		total=$((a+b+c+idle))
		cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
		#cpu_temp=`sensors | awk '/^Package/ {print $4}'`

		echo -e "cpu: $cpu% "
}

mem(){
	mem=`free | awk '/Mem/ {printf "%d/%d\n", $3 / 1024.0, $2 / 1024.0 / 1024.0}'`
	echo -e "ram: $mem"
}

btc() {
	saida=`curl -s https://www.mercadobitcoin.net/api/BTC/ticker | jq -r '.ticker.last' | cut -d . -f 1`
	saida=$(fmtmoney $saida)
	echo -e "btc: $saida"
}

eth() {
	saida=`curl -s https://www.mercadobitcoin.net/api/ETH/ticker | jq -r '.ticker.last' | cut -d . -f 1`
	saida=$(fmtmoney $saida)
	echo -e "eth: $saida"
}

gitstatus() {
	GSTATUS=""
	for WS in $(cat /home/$USER/.workspaces.txt);
	do
		OUTPUT=`git -C $WS status`
		OK=`echo $OUTPUT | grep "up to date"`
		PROJECT=`echo $WS | rev | cut -d'/' -f1 | rev`
		EMOJI_OK=👍
		[ -z "$OK" ] && EMOJI_OK=👎
		BRANCH=`echo $OUTPUT | cut -d' ' -f 3`
	
		GSTATUS="$GSTATUS $PROJECT ($BRANCH) $EMOJI_OK "
	done
	echo -e "$GSTATUS"
}

check_srv_onl() {
	ping -w 5 -c1 srv > /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "🟢 srv"	
	else
		echo -e "🔴 srv"
	fi
}

next_agd() {
	nagd=`calcurse --next | tail -1 | cut -c 2- | sed -e 's/^ *//'`
	[[ "" != "$nagd" ]] && echo -e "📖 $nagd"

}

firstit=1
while true; do
	segs=`date +"%S"` #pega ult segundos, se for 00 passou 1 minuto
	mins=`date +"%M" | cut -c 2-` #pega ult caracter dos minutos, se for 0 passou uma dezena de minutos

	if [ "$mins" = "0" -o "$mins" = "5" -o $firstit == 1 ]
	then
		next_agdv=$(next_agd)
		BTC=$(btc)
		ETH=$(eth)
		srv_onl=$(check_srv_onl)
		LOOPS=0	
	fi

	if [ "$segs" = "00" -o $firstit == 1 ]
	then
		dtev=$(dte)
	fi
	xsetroot -name " $next_agdv $BTC $ETH $(cpu) $(mem) $dtev "
	sleep 10s
	firstit=0
done &
