function hintR(l,q)
{
var _pk="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
var r=_pk+"_-,.              ",i=0,k='';
for(;i<l;i++)k+=r.charAt(Math.floor(Math.random()*r.length));
k+=q?"?":"!";
return k;
}
