do local
a={e='\27[0m',br='\27[1m',di='\27[2m',it='\27[3m',un='\27[4m',bl='\27[5m',re='\27[7m',hi='\27[8m',k='\27[30m',r='\27[31m',g='\27[32m',y='\27[33m',b='\27[34m',m='\27[35m',c='\27[36m',w='\27[37m',_k='\27[40m',_r='\27[41m',_g='\27[42m',_y='\27[43m',_b='\27[44m',_m='\27[45m',_c='\27[46m',_w='\27[47m'}local
b=string.find(package.path,'\\')~=nil;if b then for c,d in pairs(a)do a[c]=''end
end;local e={"<metatable>",colors=a.it..a.y}local f="   "local g=" "local
h,i,j=1,2,3;local k={{"{",colors=a.br},",",{"}",colors=a.br}}local l=30;local
m=l*2;local
n={"Cherry","Apple","Lemon","Blueberry","Jam","Cream","Rhubarb","Lime","Butter","Grape","Pomegranate","Sugar","Cinnamon","Avocado","Honey"}local
o={a.r,a.g,a.y,a.b,a.m,a.c}local
p={['and']=true,['break']=true,['do']=true,['else']=true,['elseif']=true,['end']=true,['false']=true,['for']=true,['function']=true,['goto']=true,['if']=true,['in']=true,['local']=true,['nil']=true,['not']=true,['or']=true,['repeat']=true,['return']=true,['then']=true,['true']=true,['until']=true,['while']=true}local
function q()local r=1;local s=1;local t=1;return function()local u=n[r]if s>1
then u=u.." "..tostring(s)end;r=r+1;if r>#n then r=1;s=s+1 end;local
v=o[t]t=t+1;if t>#o then t=1 end;return{u,colors=a.un..v}end end;local function
w()return{occur={},named={},next_name=q(),prev_indent='',next_indent=f,line_len=0,max_width=78,result=''}end;local
x={}local y,z;function y(A,B)local C=x[type(A)]if C then return C(A,B)end;if
B.occur[A]then if not B.named[A]then
B.named[A]=B.next_name()end;return{id=A}else
B.occur[A]=true;return{id=A,def=tostring(A)}end
end;x['function']=function(A,B)if B.occur[A]then if not B.named[A]then
B.named[A]=B.next_name()end else B.occur[A]=true end;return{id=A}end;function
x.table(A,B)if B.occur[A]then if not B.named[A]then
B.named[A]=B.next_name()end;return{id=A}else B.occur[A]=true;local
u={bracket=k}local D={"=",colors=a.di}local E=getmetatable(A)if E then
E=y(E,B)table.insert(u,{e,D,E})end;for c,d in pairs(A)do if z(c)then
c={c,colors=a.m}else
c=y(c,B)end;d=y(d,B)table.insert(u,{c,D,d})end;return{id=A,def=u}end
end;function x.string(A,B)if#A<=m then local
F=string.format('%q',A)F=string.gsub(F,'\n','n')return{F,colors=a.g}else local
F=string.format('%q',string.sub(A,1,l))F=string.gsub(F,'\n','n')local
G=string.format('%q',string.sub(A,-l))G=string.gsub(G,'\n','n')return{F,{"...",colors=a.di},G,colors=a.g,sep='',tight=true}end
end;function x.number(A,B)return{tostring(A),colors=a.m..a.br}end;function
z(A)if type(A)~='string'then return false end;if
string.find(A,'^[_%a][_%a%d]*$')then if p[A]then return false else return true
end else return false end end;local function H(I,B)if type(I)=='table'then if
I.id then local J=B.named[I.id]local K=I.def;if J then local L={"<",type(I.id)," "
, J,">",colors=a.it,sep='',tight=true}if K then
return{L,{"is",colors=a.di},H(I.def,B)}else return L end else if K then return
H(I.def,B)else return{"<",type(I.id),">",colors=a.it,sep='',tight=true}end end
elseif I.bracket then for M,N in ipairs(I)do I[M]=H(N,B)end;return I else for
M,N in ipairs(I)do I[M]=H(N,B)end;return I end else return I end end;local
O,P,Q,R,S,T,U,V,W,X,Y,Z,_;function P(I,B)if type(I)=='string'then return
S(I,B)elseif I.bracket then return Q(I,B)else return R(I,B)end end;function
Q(a0,B)if#a0==0 then local
a1={a0.bracket[h],a0.bracket[j],sep='',tight=true}return P(a1,B)end;local
a2=O(a0)if a2<=Z(B)then return T(a0,B)elseif a2<=_(B)then V(B)return T(a0,B)else
return U(a0,B)end end;function T(a0,B)P(a0.bracket[h],B)X(" ",B)P(a0[1],B)for
M=2,#a0 do local N=a0[M]X(a0.bracket[i],B)X(" ",B)P(N,B)end;X(" "
,B)P(a0.bracket[j],B)end;function U(a0,B)local a3=B.prev_indent;local
a4=B.next_indent;P(a0.bracket[h],B)B.prev_indent=a4;B.next_indent=a4 ..f;for
M=1,#a0-1 do local N=a0[M]W(B)X(a4,B)P(N,B)X(a0.bracket[i],B)end;do local
N=a0[#a0]W(B)X(a4,B)P(N,B)end;W(B)X(a3,B)P(a0.bracket[j],B)B.prev_indent=a3;B.next_indent=a4
end;function R(I,B)if#I>0 then if I.tight then local a2=O(I,B)if a2>Z(B)and
a2<=_(B)then V(B)end end;if I.colors then Y(I.colors,B)end;P(I[1],B)for M=2,#I
do local N=I[M]if I.colors then Y(I.colors,B)end;X(I.sep or g,B)P(N,B)end;if
I.colors then Y(a.e,B)end end end;function S(I,B)local a2=O(I)if a2>Z(B)and
a2<=_(B)then V(B)end;X(I,B)end;function O(I,B)if type(I)=='string'then return#I
end;local u=0;if I.bracket then if#I==0 then return
O(I.bracket[h])+O(I.bracket[j])end;u=u+O(I.bracket[h])+O(I.bracket[j])+2;u=u+(#I-1)*(#I.bracket[i]+1)else
if#I==0 then return 0 end;u=u+(#I-1)*#(I.sep or g)end;for a5,N in ipairs(I)do
u=u+O(N,B)end;return u end;function
V(B)B.result=B.result.."\n"B.line_len=0;X(B.next_indent,B)end;function
W(B)B.result=B.result.."\n"B.line_len=0 end;function
X(a1,B)B.result=B.result..a1;B.line_len=B.line_len+#a1 end;function
Y(a1,B)B.result=B.result..a1 end;function Z(B)return
math.max(0,B.max_width-B.line_len)end;function _(B)return
math.max(0,B.max_width-#B.next_indent)end;mm=function(A)if A==nil then
print(nil)else local B=w()local
I=y(A,B)I=H(I,B)P(I,B)print(a.e..B.result..a.e)end end end
