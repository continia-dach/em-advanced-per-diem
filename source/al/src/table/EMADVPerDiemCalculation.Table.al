table 62082 "EMADV Per Diem Calculation"
{
    Caption = 'EMADV Per Diem Calculation';
    DataClassification = CustomerContent;
    LookupPageId = "EMADV Per Diem Calc. List";
    DrillDownPageId = "EMADV Per Diem Calc. List";

    fields
    {
        field(1; "Per Diem Entry No."; Integer)
        {
            Caption = 'Per Diem Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "CEM Per Diem";
        }
        field(3; "Per Diem Det. Entry No."; Integer)
        {
            Caption = 'Per Diem Detail Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "CEM Per Diem Detail";
        }
        field(5; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        /*field(5; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }*/
        field(10; "From DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(11; "To DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
        }

        field(15; "Country/Region"; Code[10])
        {
            Caption = 'Country/Region';
            DataClassification = CustomerContent;
            TableRelation = "CEM Country/Region";
        }
        field(16; "Destination Name"; Text[50])
        {
            CalcFormula = Lookup("CEM Country/Region".Name WHERE(Code = FIELD("Country/Region")));
            Caption = 'Country/Region Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Day Duration"; Duration)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Per Diem Entry No.", "Per Diem Det. Entry No.", "Entry No.", "From DateTime")
        {
            Clustered = true;
        }
        key(Key2; "From DateTime")
        {
        }
    }
}
