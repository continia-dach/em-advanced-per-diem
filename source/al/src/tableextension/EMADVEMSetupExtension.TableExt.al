tableextension 62080 "EMADV EM Setup Extension" extends "CEM Expense Management Setup"
{
    fields
    {
        field(62080; "Use Custom Per Diem Engine"; Boolean)
        {
            Caption = 'Use Custom Per Diem Engine';
            DataClassification = CustomerContent;
        }
    }
}
