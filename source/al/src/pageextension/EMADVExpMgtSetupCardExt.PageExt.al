pageextension 62080 "EMADV Exp. Mgt. Setup Card Ext" extends "CEM Expense Management Setup"
{
    layout
    {
        addbefore("Enable per diem destinations")
        {
            field("Use Custom Per Diem Engine"; Rec."Use Custom Per Diem Engine")
            {
                ApplicationArea = All;
            }
        }
    }
}
