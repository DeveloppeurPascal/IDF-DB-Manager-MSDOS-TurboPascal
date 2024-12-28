unit idf_options;
{
Auteur: Premartin Patrick
Date: 19/09/1991. 23/09/1991. 26/03/1992. 11/09/1992. 12/09/1992.
Langage: Turbo Pascal 6.0

But: Gestion du menu OPTIONS de Index 4.x
}
interface
uses
    app,
    msgbox,
    u_msg;

procedure idf_edit_modify (self : tapplication);
procedure idf_sort_base (self : tapplication);
procedure idf_search_data (self : tapplication);
procedure idf_insert_data (self : tapplication);

implementation
uses
    idf_enreg,
    idf_var,
    idf_searcher,
    idf_sort,
    idf_viewer,
    views;

procedure idf_edit_modify (self : tapplication);
var
   edit : p_viewer;
   result : word;
   enreg,
   enreg2 : p_enreg;
begin
  num_enreg := 1;
  enreg := first;
  repeat
    edit := new (p_viewer, init (get_msg (48), enreg, num_enreg, bf_edit));
    if (self.validview (edit) <> nil)
    then
      begin
        result := desktop^.execview (edit);
        dispose (edit, done);
        case result of
          cm_previous : if (enreg^.previous <> nil)
                        then
                          begin
                            dec (num_enreg);
                            enreg := enreg^.previous;
                          end
                        else
                          begin
                            num_enreg := nb_enreg;
                            enreg := last;
                          end;
                        {endif}
          cm_next : if (enreg^.next <> nil)
                    then
                      begin
                        inc (num_enreg);
                        enreg := enreg^.next;
                      end
                    else
                      begin
                        num_enreg := 1;
                        enreg := first;
                      end;
                    {endif}
          cm_erase : begin
            modif := true;
            if (first = enreg)
            then
              first := enreg^.next;
            {endif}
            if (last = enreg)
            then
              last := enreg^.previous;
            {endif}
            enreg2 := enreg^.next;
            if (enreg2 = nil)
            then
              begin
                enreg2 := enreg^.previous;
                if (enreg2 = nil)
                then
                  enreg2 := first;
                {endif}
              end;
            {endif}
            dispose (enreg, done);
            dec (nb_enreg);
            if (num_enreg > nb_enreg)
            then
              num_enreg := nb_enreg;
            {endif}
            enreg := enreg2;
          end;
        end;
      end
    else
      result := cmcancel;
    {endif}
  until ((enreg = nil) or (result = cmok) or (result = cmcancel) or (result = cmdefault));
end; { Idf_Edit_Modify }

procedure idf_sort_base (self : tapplication);
begin
end; { Idf_Sort_Base }

procedure idf_search_data (self : tapplication);
begin
end; { Idf_Search_Data }

procedure idf_insert_data (self : tapplication);
var
   enreg : p_enreg;
   edit : p_viewer;
   result : word;
begin
  num_enreg := succ (nb_enreg);
{$ifdef demo_vers}
  if (num_enreg > 50)
  then
    begin
      result := messagebox (get_msg (25), nil, mfcancelbutton);
      exit;
    end;
  {endif}
{$endif}
  enreg := new (p_enreg, init (last, nil));
  edit := new (p_viewer, init (get_msg (49), enreg, num_enreg, bf_insert));
  if (self.validview (edit) <> nil)
  then
    begin
      result := desktop^.execview (edit);
      dispose (edit, done);
      case result of
        cmdefault,
        cmok : begin
          inc (nb_enreg);
          if (first = nil)
          then
            begin
              first := enreg;
              last := enreg;
              enreg^.previous := nil;
              enreg^.next := nil;
            end
          else
            begin
              last^.next := enreg;
              last := enreg;
            end;
          {endif}
        end;
      else
        dispose (enreg, done);
      end;
    end
  else
    dispose (enreg, done);
  {endif}
end; { Idf_Insert_Data }

end. { Fin de l'unit‚ 'Idf_Options'. }
