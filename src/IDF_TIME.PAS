unit idf_time_date;
{
Auteur: Premartin Patrick
Date: 19/09/1991.
Langage: Turbo Pascal 6.0

But: Changer l'heure courante.
}
interface
uses
    app;

procedure change_time (self : tapplication);
procedure change_date (self : tapplication);

implementation
uses
    u_calendar,
    u_horloge,
    views;

procedure change_time (self : tapplication);
var
   horloge : p_horloge_window;
   result : word;
begin
     horloge := new (p_horloge_window, init);
     horloge^.helpctx := hcnocontext;
     if (self.validview (horloge) <> nil)
     then
         begin
              result := desktop^.execview (horloge);
              dispose (horloge, done);
         end;
     {endif}
end; { Change_Time }

procedure change_date (self : tapplication);
var
   calendrier : P_Calendar_Window;
   result : word;
begin
     calendrier := New (P_Calendar_Window, Init);
     calendrier^.HelpCtx := hcnocontext;
     if (self.validview (calendrier) <> nil)
     then
         begin
              result := desktop^.execview (calendrier);
              dispose (calendrier, done);
         end;
     {endif}
end; { Change_Date }

end. { Fin de l'unit‚ 'Idf_Time_Date'. }
