pageextension 62087 "EMADV Sttl. Per Diem Subp Ext" extends "CEM Sttl. - Per Diem Subpage"
{
    layout
    {
        addbefore("Destination Country/Region")
        {
            field("Departure Country/Region"; Rec."Departure Country/Region")
            {
                ApplicationArea = All;
                Caption = 'Departure Country/Region';
                ToolTip = 'Country/Region where the employee is departing from.';
            }
        }
    }
    actions
    {
        addafter(Details)
        {
            action(ShowCalculationList)
            {
                ApplicationArea = All;
                Caption = 'Show Calculation';
                RunObject = page "EMADV Per Diem Calc. List";
                RunPageLink = "Per Diem Entry No." = field("Entry No.");
                RunPageMode = View;
                Image = ShowList;
            }
        }
    }
}
