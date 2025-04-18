#!/bin/awk -f

function oprint(t) { if(nr == 0) otext = otext t; else otext = otext t; }

function nextil(t) {
	if(!match(t, /[`<\[*_\\]|(\!\[)/)) return t
	t1 = substr(t, 1, RSTART - 1)
	tag = substr(t, RSTART, RLENGTH)
	t2 = substr(t, RSTART + RLENGTH)
	if(ilcode && tag != "`"){ return t1 tag nextil(t2);}
	if(tag == "`"){
		if(sub(/^`/, "", t2)){ if(!match(t2, /``/)) return t1 nextil(t2); ilcode2 = !ilcode2; }
		else if(ilcode2) return t1 tag nextil(t2);
		tag = "<pre>";
		if(ilcode){ tag = "</pre>"; }
		ilcode = !ilcode; return t1 tag nextil(t2);
	}
	if(tag == "\\"){ if(match(t2, /^[\\*_{}\[\]()#+\-\.!]/)){ tag = substr(t2, 1, 1)
	t2 = substr(t2, 2); }
	return t1 tag nextil(t2); }

	if(tag == "<"){
		if(match(t2, /^[a-z\/][^>]*>/)){
			tag = tag substr(t2, RSTART, RLENGTH)
			t2 = substr(t2, RLENGTH + 1)
			return t1 tag nextil(t2);
		}
        }

        if(tag == "["){
		if(!match(t2, /(\[.*\])|(\(.*\))/)) return t1 tag nextil(t2); match(t2, /^[^\]]*(\[[^\]]*\][^\]]*)*/)
		linktext = substr(t2, 1, RLENGTH)
		t2 = substr(t2, RLENGTH + 2); if(match(t2, /^\(/)){ match(t2, /^[^\)]+(\([^\)]+\)[^\)]*)*/)
		url = substr(t2, 2, RLENGTH - 1)
		pt2 = substr(t2, RLENGTH + 2)
		return t1 "<a href="url">"nextil(linktext)"</a>" nextil(pt2); }
	}

	 if(match(tag, /[*_]/)){ ntag = tag; if(sub("^" tag, "", t2)){ if(stag[ns] == tag && match(t2, "^" tag)) t2 = tag t2; else ntag = tag tag; } n = length(ntag)
	tag = (n == 2) ? "b" : "i"
	if(match(t1, / $/) && match(t2, /^ /)) return t1 tag nextil(t2)
	if(stag[ns] == ntag){ tag = "/" tag; ns--; } else stag[++ns] = ntag
	tag = "<" tag ">"
	return t1 tag nextil(t2); } }

function inline(t){ ilcode = 0; ilcode2 = 0; ns = 0; return nextil(t); }

function printp(tag){ if(!match(text, /^[ ]*$/)){ text = inline(text);if(tag != "") oprint("<" tag ">" text "</" tag ">"); else oprint(text); } text = ""; }

{
	for(nnl = 0; nnl < nl; nnl++)
	if(match(block[nnl + 1], /[ou]l/) && !sub(/^(    |	)/, ""))
	    break;
}

{ newli = 0; }

!hr && (nnl != nl || !text || block[nl] ~ /[ou]l/) && /^ ? ? ?[*+-]( +|	)/ {
    sub(/^ ? ? ?- *( +| )/, "");
    nnl++;
    nblock[nnl] = "ul";
    newli = 1;
}

newli { if(blank && nnl == nl && !par) par = "p"; blank = 0; printp(par); if(nnl == nl && block[nl] == nblock[nl]) oprint("<li>"); }

nnl != nl || nblock[nl] != block[nl] {
    printp(par);
    b = (nnl > nl) ? nblock[nnl] : block[nl];
    par = (match(b, /[ou]l/)) ? "" : "p";
}

nnl < nl  { for(; nl > nnl || (nnl == nl && pblock[nl] != block[nl]); nl--){ oprint("</" block[nl] ">"); } }

nnl > nl {
    for(; nl < nnl; nl++){
	block[nl + 1] = nblock[nl + 1];
	oprint("<" block[nl + 1] ">");
	if(match(block[nl + 1], /[ou]l/))
	    oprint("<li>");
    }
}

/^# / { par = "h1"; sub(/^# +/, ""); }; (/^## /) { par = "h2"; sub(/^## +/, ""); }; (/^### /) { par = "h3"; sub(/^### +/, ""); }

/^$/ { printp(par); par = "p"; next; }
{ text = (text ? text " " : "") $0; }
END{printp(par);printf(otext);}

