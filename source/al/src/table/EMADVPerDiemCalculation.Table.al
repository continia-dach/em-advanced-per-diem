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
        field(5; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(10; "From Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(11; "To Time"; Time)
        {
            DataClassification = CustomerContent;
        }

        field(15; "Destination Country/Region"; Code[10])
        {
            Caption = 'Destination Country/Region';
            DataClassification = CustomerContent;
            TableRelation = "CEM Country/Region";
        }
        field(16; "Destination Name"; Text[50])
        {
            CalcFormula = Lookup("CEM Country/Region".Name WHERE(Code = FIELD("Destination Country/Region")));
            Caption = 'Destination Name';
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
        key(Key1; "Per Diem Entry No.", "Date", "From Time")
        {
            Clustered = true;
        }
    }
}
