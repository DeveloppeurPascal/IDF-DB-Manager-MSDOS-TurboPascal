unit idf_viewer;
{
Auteur: Premartin Patrick
Date: 19/09/1991. 23/09/1991. 26/03/1992. 11/09/1992. 12/09/1992.
Langage: Turbo Pascal 6.0
}
interface
uses
    dialogs,
    drivers,
    objects,
    u_msg,
    u_dialogs,
    u_idf,
    idf_enreg;

const
     bf_ok = 1;
     bf_cancel = 2;
     bf_previous = 4;
     bf_next = 8;
     bf_erase = 16;
     bf_edit = bf_ok+bf_cancel+bf_previous+bf_next+bf_erase;
     bf_insert = bf_ok+bf_cancel;
     bf_search = bf_ok+bf_cancel;
     bf_find = bf_ok+bf_cancel+bf_previous+bf_next+bf_erase;

     cm_previous = 2000;
     cm_next = 2001;
     cm_erase = 2002;

type
    p_viewer = ^o_viewer;
    o_viewer =
      object (tdialog)
        lig : array [1..nb_max_champs] of pinputline;
        adr_enreg : p_enreg;

        constructor init (atitre : string; enreg : p_enreg; num : word; buttons : word);
        procedure handleevent (var event : tevent); virtual;
        function num2str (nb : longint) : string;
        function str2num (ch : string) : longint;
        procedure modifie;
      end;

implementation
uses
    idf_var,
    views;

constructor o_viewer.init (atitre : string; enreg : p_enreg; num : word; buttons : word);
var
   r : trect;
   i,
   j : byte;
   ch : string;
   data_rec : record
                    ch : string;
   end;
   data_rec2 : record
                     nb : longint;
   end;
begin
     r.assign (1, 1, 75, 8+nb_champs*2);
     tdialog.init (r, atitre);
     adr_enreg := enreg;
     helpctx := hcnocontext;
     options := options+ofcentered;
     r.assign (size.x -20, 1, pred (size.x), 2);
     insert (new (pstatictext, init (r, 'Nø '+num2str (num)+'/'+num2str (nb_enreg))));
     for i := 2 to nb_champs do
       begin
         r.assign (2, succ (i*2)+1, succ (champs [i].taille)+2, succ (i*2)+2);
         case (champs [i].typ) of
           2 :
             begin
               ch := '';
               for j := 1 to pred (champs [i].taille) do
                   ch := ch + '9';
               {endfor}
               lig [i] := new (p_input_number, init (r, 0, str2num (ch)));
               data_rec2.nb := str2num (adr_enreg^.get_champ (i));
               lig [i]^.setdata (data_rec2);
             end;
         else
           lig [i] := new (pinputline, init (r, pred (champs [i].taille)));
           data_rec.ch := adr_enreg^.get_champ (i);
           lig [i]^.setdata (data_rec);
         end;
         lig [i]^.helpctx := helpctx;
         insert (lig [i]);
         r.assign (2, succ (i*2), succ (champs [i].taille)+2, succ (i*2)+1);
         insert (new (pstatictext, init (r, titre^.get_champ (i))));
       end;
     {endfor}
     if (buttons and bf_ok <> 0)
     then
         begin
              r.assign (3, size.y-3, 5+length (get_msg (26)), pred (size.y));
              insert (new (pbutton, init (r, get_msg (26), cmok, bfdefault)));
         end;
     {endif}
     if (buttons and bf_cancel <> 0)
     then
         begin
              r.assign (14, size.y-3, 16+length (get_msg (44)), pred (size.y));
              insert (new (pbutton, init (r, get_msg (44), cmcancel, bfnormal)));
         end;
     {endif}
     if (buttons and bf_previous <> 0)
     then
         begin
              r.assign (29, size.y-3, 31+length (get_msg (45)), pred (size.y));
              insert (new (pbutton, init (r, get_msg (45), cm_previous, bfnormal)));
         end;
     {endif}
     if (buttons and bf_next <> 0)
     then
         begin
              r.assign (46, size.y-3, 48+length (get_msg (46)), pred (size.y));
              insert (new (pbutton, init (r, get_msg (46), cm_next, bfnormal)));
         end;
     {endif}
     if (buttons and bf_erase <> 0)
     then
         begin
              r.assign (59, size.y-3, 61+length (get_msg (47)), pred (size.y));
              insert (new (pbutton, init (r, get_msg (47), cm_erase, bfnormal)));
         end;
     {endif}
     i := 1;
     r.assign (2, succ (i*2), succ (champs [i].taille)+2, succ (i*2)+1);
     insert (new (pstatictext, init (r, titre^.get_champ (i))));
     r.assign (2, succ (i*2)+1, succ (champs [i].taille)+2, succ (i*2)+2);
     case (champs [i].typ) of
       2 :
         begin
           ch := '';
           for j := 1 to pred (champs [i].taille) do
             ch := ch + '9';
           {endfor}
           lig [i] := new (p_input_number, init (r, 0, str2num (ch)));
           data_rec2.nb := str2num (adr_enreg^.get_champ (i));
           lig [i]^.setdata (data_rec2);
         end;
     else
       lig [i] := new (pinputline, init (r, pred (champs [i].taille)));
       data_rec.ch := adr_enreg^.get_champ (i);
       lig [i]^.setdata (data_rec);
     end;
     lig [i]^.helpctx := helpctx;
     insert (lig [i]);
end; { O_Viewer.Init }

procedure o_viewer.handleevent (var event : tevent);
var
   i : byte;
begin
     if (event.what = evcommand)
     then
         case event.command of
           cmcancel :
             begin
               for i := 1 to nb_champs do
                 if (lig [i] <> nil)
                 then
                   dispose (lig [i], done);
                 {endif}
               {endfor}
               endmodal (cmcancel);
             end;
           cmok,
           cmdefault,
           cm_erase,
           cm_previous,
           cm_next :
             begin
               modifie;
               endmodal (event.command);
             end;
         end;
     {endif}
     tdialog.handleevent (event);
end; { O_Viewer.HandleEvent }

function o_viewer.num2str (nb : longint) : string;
var
   ch : string;
begin
     str (nb, ch);
     num2str := ch;
end; { O_Viewer.Num2Str }

function o_viewer.str2num (ch : string) : longint;
var
   nb,
   res : integer;
begin
     {$r-}
     val (ch, nb, res);
     {$r+}
     str2num := nb;
end; { O_Viewer.Str2Num }

procedure o_viewer.modifie;
var
   i : integer;
   data_rec : record
                    ch : string;
   end;
   data_rec2 : record
                     nb : longint;
   end;
begin
  modif := true;
  for i := 1 to nb_champs do
    begin
      case (champs [i].typ) of
        2 :
          begin
            lig [i]^. getdata (data_rec2);
            adr_enreg^.set_champ (i, num2str (data_rec2.nb));
          end;
      else
        lig [i]^.getdata (data_rec);
        adr_enreg^.set_champ (i, data_rec.ch);
      end;
      if (lig [i] <> nil)
      then
        dispose (lig [i], done);
      {endif}
    end;
  {endfor}
end; { O_Viewer.Modifie }

end. { Fin de l'unite 'Idf_Viewer'. }
