
function k = AG1getKeyboardNumber
% Gets laptop internal keyboard for Ben's laptop, INERTIA

d=PsychHID('Devices');
k = 0;

for n = 1:length(d)
<<<<<<< HEAD
    if (d(n).productID==566)&&(strcmp(d(n).usageName,'Keyboard'));  %560 for Recca % 538 for laptop kb, 544 for alan external, 516 for rm 410
=======
    if (d(n).productID==594)&&(strcmp(d(n).usageName,'Keyboard'));  %560 for Recca % 538 for laptop kb, 544 for alan external, 516 for rm 410
>>>>>>> e22324c742b4755ee6f4ebbcadb2d10b10fb68ac
        k=n;
        break
    end
end
