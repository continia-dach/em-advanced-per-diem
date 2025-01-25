pageextension 62086 "EMADV Countries/Regions Ext" extends "CEM Countries/Regions"
{
    layout
    {
        addafter(Name)
        {
            field("Domestic Country"; Rec."Domestic Country")
            {
                ApplicationArea = All;
            }
        }
    }
}
