table 62081 "EMADV Cust PerDiem Rate Detail"
{
    Caption = 'EMADV Custom Per Diem Rates';
    DataClassification = CustomerContent;
    LookupPageId = "EMADV Cust. PD Rate Details";

    fields
    {
        field(1; "Per Diem Group Code"; Code[20])
        {
            Caption = 'Per Diem Group Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "CEM Per Diem Group";
        }
        field(2; "Destination Country/Region"; Code[10])
        {
            Caption = 'Destination Country/Region';
            DataClassification = CustomerContent;
            TableRelation = "CEM Country/Region";
        }
        field(3; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(4; "Accommodation Allowance Code"; Code[20])
        {
            Caption = 'Accommodation Allowance Code';
            DataClassification = CustomerContent;
            TableRelation = "CEM Allowance" WHERE(Type = FILTER(' ' | Accommodation));
        }
        field(5; "Calculation Method"; enum "EMADV Per Diem Calc. Method")
        {
            Caption = 'Calculation method';
            DataClassification = CustomerContent;

        }
        field(6; "From Hour"; Integer)
        {
            Caption = 'From Hour';
            MinValue = 0;
            MaxValue = 23;
            DataClassification = CustomerContent;
        }
        field(7; "Deduction Type"; enum "EMADV Per Diem Deduction Type")
        {
            Caption = 'Deduction Type';
            DataClassification = CustomerContent;
        }
        field(8; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Deduction Amount"; Decimal)
        {
            Caption = 'Deduction Amount';
            DataClassification = CustomerContent;
        }

        field(11; "Deduction Description"; Text[50])
        {
            Caption = 'Deduction Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Per Diem Group Code", "Destination Country/Region", "Start Date", "Accommodation Allowance Code", "Calculation Method", "From Hour", "Deduction Type", "Line No.")
        {
            Clustered = true;
        }
    }
}
