fun SUM(a[]:int):int
{ var i,sum:int;
sum:= 0; i:= 0;
while i<size(a) do
{ sum:= sum + a[i];
i:= i+1;
};
return sum;
};
