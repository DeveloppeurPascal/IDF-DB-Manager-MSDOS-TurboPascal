unit idf_base;
{
Auteur: Premartin Patrick
Date: 18/09/1991. 19/09/1991. 26/03/1992. 31/03/1992. 11/09/1992. 12/09/1992.
Langage: Turbo Pascal 6.0

But: Gestion de la base de donnees courante.
}
interface
uses
    app,
    u_msg;

procedure save_base (nom_fich : string);
procedure load_base (nom_fich : string);
procedure create_base (nom_fich : string; self : tapplication);

implementation
uses
    idf_enreg,
    idf_var,
    msgbox,
    u_idf,
    objects,
    u_dialogs,
    dialogs,
    u_chaine,
    views;

procedure clear_data_base;
var
   enreg1,
   enreg2 : p_enreg;
begin
     if (titre <> nil)
     then
         dispose (titre, done);
     {endif}
     enreg1 := first;
     while not (enreg1 = nil) do
           begin
                enreg2 := enreg1^.next;
                dispose (enreg1, done);
                enreg1 := enreg2;
           end;
     {endwhile}
     titre := nil;
     first := nil;
     last := nil;
     num_enreg := 0;
     nb_enreg := 0;
end; { Clear_Data_Base }

procedure save_base (nom_fich : string);
var
   fich : file;
   result : word;
   enreg : p_enreg;
begin
     modif := false;
     assign (fich, nom_fich);
     {$i-}
     rewrite (fich, 1);
     {$i+}
     if (ioresult <> 0)
     then
         result := messagebox (get_msg (50), nil, mferror+mfcancelbutton)
     else
         begin
              save_idf_header (fich, nb_champs, champs);
              write_idf (fich, nb_champs, champs, titre^.adr);
              enreg := first;
              while (enreg <> nil) do
                    begin
                         write_idf (fich, nb_champs, champs, enreg^.adr);
                         enreg := enreg^.next;
                    end;
              {endwhile}
              close (fich);
         end;
     {endif}
end; { Save_Base }

procedure load_base (nom_fich : string);
var
   fich : file;
   result : word;
   enreg : p_enreg;
begin
     modif := false;
     activ := true;
     assign (fich, nom_fich);
     {$i-}
     reset (fich, 1);
     {$i+}
     if (ioresult <> 0)
     then
         result := messagebox (get_msg (51), nil, mferror+mfcancelbutton)
     else
         begin
              clear_data_base;
              init_idf (fich, nb_champs, champs);
              titre := new (p_enreg, init (nil, nil));
              read_idf (fich, nb_champs, champs, titre^.adr);
              first := new (p_enreg, init (nil, nil));
              enreg := first;
              nb_enreg := 0;
              while not (eof (fich) or (enreg = nil)) do
                    begin
                         read_idf (fich, nb_champs, champs, enreg^.adr);
                         enreg^.next := new (p_enreg, init (enreg, nil));
                         last := enreg;
                         inc (nb_enreg);
                         enreg := enreg^.next;
                    end;
              {endwhile}
              dispose (enreg, done);
              close (fich);
              num_enreg := 1;
         end;
     {endif}
end; { Load_Base }

procedure create_base (nom_fich : string; self : tapplication);
type
    string70 = string [70];

var
   boite : pdialog;
   r : trect;
   l1 : p_input_number;
   l2 : pinputline;
   b : pradiobuttons;
   res : word;
   data : record                { Donn‚e utilis‚e pour le nombre de champs. }
            nb : longint;
   end;
   data2 : record               { Donn‚e utilis‚e pour chaque champ. }
             nb : longint;
             typ : word;
             ch : string70;
   end;
   i : byte;
   ch : array [1..8] of string;
begin
  modif := false;
  activ := false;
  nb_enreg := 0;
  num_enreg := 0;
  clear_data_base;

{ Cette boite me permet de saisir le nombre de champs de la nouvelle base. }
  r.assign (1, 1, 30, 8);
  boite := new (pdialog, init (r, get_msg (52)));
  with boite^ do
    begin
      options := options or ofcentered;
      helpctx := hcnocontext;
      r.assign (size.x-20, size.y-3, size.x-14, size.y-1);
      insert (new (pbutton, init (r, get_msg (26), cmOk, bfdefault)));
      r.assign (size.x-13, size.y-3, size.x-3, size.y-1);
      insert (new (pbutton, init (r, get_msg (44), cmCancel, bfnormal)));
      r.assign (24, 2, 27, 3);
      l1 := new (p_input_number, init (r, 1, 8));
      l1^.helpctx := helpctx;
      insert (l1);
      r.assign (3, 2, 24, 3);
      insert (new (plabel, init (r, copy (get_msg (53), 1, 21), l1)));
    end;
  {endwith}
  if (self.validview (boite) <> nil)
  then
    begin
      data.nb := 1;
      boite^.setdata (data);
      if (desktop^.execview (boite) <> cmcancel)
      then
        begin
          boite^.getdata (data);
          nb_champs := data.nb;
          dispose (boite, done);
        end
      else
        begin
          dispose (boite, done);
          exit;
        end;
      {endif}
    end;
  {endif}

{ Nous devons maintenant choisir le titre, la longueur et le type de chaque
champ. }
  for i := 1 to nb_champs do
    begin
      r.assign (1, 1, 75, 16);
      boite := new (pdialog, init (r, get_msg (54)+' '+chr (i+48)));
      with boite^ do
        begin
          options := options or ofcentered;
          helpctx := hcnocontext;

          r.assign (2, 7, 7, 8);
          l1 := new (p_input_number, init (r, 1, 70));
          l1^.helpctx := helpctx;
          insert (l1);
          r.assign (2, 6, 2+length (get_msg (58)), 7);
          insert (new (plabel, init (r, get_msg (58), l1)));
          r.assign (10, 10, 30, 12);
          b := new (pradiobuttons, init (r, newsitem (copy (get_msg (56), 1, 16),
                                            newsitem (copy (get_msg (57), 1, 16),
                                            nil))
          ));
          b^.helpctx := helpctx;
          insert (b);
          r.assign (3, 10, 3+length (get_msg (55)), 11);
          insert (new (plabel, init (r, get_msg (55), b)));
          r.assign (size.x-20, size.y-3, size.x-18+length (get_msg (26)), size.y-1);
          insert (new (pbutton, init (r, get_msg (26), cmOk, bfdefault)));
          r.assign (size.x-13, size.y-3, size.x-11+length (get_msg (44)), size.y-1);
          insert (new (pbutton, init (r, get_msg (44), cmCancel, bfnormal)));
          r.assign (2, 4, 73, 5);
          l2 := new (pinputline, init (r, 70));
          l2^.helpctx := helpctx;
          insert (l2);
          r.assign (2, 3, 2+length (get_msg (59)), 4);
          insert (new (plabel, init (r, get_msg (59), l2)));
        end;
      {endwith}
      if (self.validview (boite) <> nil)
      then
        begin
          data2.ch := '';
          data2.nb := 1;
          data2.typ := 0;
          boite^.setdata (data2);
          if (desktop^.execview (boite) <> cmcancel)
          then
            begin
              boite^.getdata (data2);
              champs [i].taille := succ (data2.nb);
              champs [i].typ := succ (data2.typ);
              ch [i] := trait (' ', champs [i].taille);
              ch [i] := data2.ch;
              dispose (boite, done);
            end
          else
            begin
              dispose (boite, done);
              exit;
            end;
          {endif}
        end;
      {endif}
    end;
  {endfor}

{ Les champs ‚tant d‚finis, il faut maintenant mettre les titres en place, et
charger le vecteur CHAMPS [].OFFSET }
  champs [1].offset := 0;
  for i := 2 to nb_champs do
    champs [i].offset := champs [pred (i)].offset + champs [pred (i)].taille;
  {endfor}
  titre := new (p_enreg, init (nil, nil));
  for i := 1 to nb_champs do
    titre^.set_champ (i, ch [i]);
  {endfor}
  activ := true;
  modif := true;
end; { Create_Base }

var
   old_exitproc : pointer;

procedure idf_base_exit; far;
begin
     clear_data_base;
     exitproc := old_exitproc;
end;

begin
     old_exitproc := exitproc;
     exitproc := @idf_base_exit;
end. { Fin de l'unit‚ 'Idf_Base'. }
