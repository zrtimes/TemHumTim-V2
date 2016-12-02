object frmParaSetting: TfrmParaSetting
  Left = 0
  Top = 0
  Caption = 'frmParaSetting'
  ClientHeight = 315
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 0
    Top = 0
    Width = 217
    Height = 315
    Align = alLeft
    Caption = #28201#28287#24230#36890#20449#27169#22359#37197#32622
    TabOrder = 0
    object pnl1: TPanel
      Left = 2
      Top = 15
      Width = 213
      Height = 26
      Align = alTop
      Caption = 'pnl1'
      TabOrder = 0
      object lbl1: TLabel
        Left = 1
        Top = 1
        Width = 60
        Height = 24
        Align = alLeft
        Caption = #27169#22359#36873#25321#65306
        Layout = tlCenter
        ExplicitHeight = 13
      end
      object cbbModu: TComboBox
        Left = 61
        Top = 1
        Width = 54
        Height = 21
        Align = alClient
        TabOrder = 0
        Text = 'cbbModu'
        OnChange = cbbModuChange
        Items.Strings = (
          #27169#22359'1'
          #27169#22359'2'
          #27169#22359'3'
          #27169#22359'4'
          #27169#22359'5'
          #27169#22359'6'
          #27169#22359'7'
          #27169#22359'8')
      end
      object btnSetComm: TBitBtn
        Left = 115
        Top = 1
        Width = 97
        Height = 24
        Align = alRight
        Caption = #35774#32622
        TabOrder = 1
        OnClick = btnSetCommClick
      end
    end
    object grp2: TGroupBox
      Left = 2
      Top = 41
      Width = 213
      Height = 272
      Align = alClient
      Caption = #36890#20449#35774#32622
      TabOrder = 1
      object strgrdCommunication: TStringGrid
        Left = 2
        Top = 15
        Width = 209
        Height = 166
        Align = alClient
        ColCount = 3
        RowCount = 6
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
      end
      object mmoMsg: TMemo
        Left = 2
        Top = 181
        Width = 209
        Height = 89
        Align = alBottom
        Lines.Strings = (
          'mmoMsg')
        TabOrder = 1
      end
    end
  end
  object grp4: TGroupBox
    Left = 473
    Top = 0
    Width = 129
    Height = 315
    Align = alClient
    Caption = 'GPS'#36890#20449#35774#32622
    TabOrder = 1
    object btnOpen: TBitBtn
      Left = 43
      Top = 234
      Width = 39
      Height = 79
      Align = alLeft
      Caption = #25171#24320#20018#21475
      TabOrder = 0
      WordWrap = True
      OnClick = btnOpenClick
    end
    object btnRefreshCom: TBitBtn
      Left = 2
      Top = 234
      Width = 41
      Height = 79
      Align = alLeft
      Caption = #26522#20030#20018#21475
      TabOrder = 1
      WordWrap = True
      OnClick = btnRefreshComClick
    end
    object chkCorrectSysTime: TCheckBox
      Left = 82
      Top = 234
      Width = 45
      Height = 79
      Align = alClient
      Caption = #21516#27493#31995#32479#26102#38388
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 2
      WordWrap = True
    end
    object pnl4: TPanel
      Left = 2
      Top = 15
      Width = 125
      Height = 219
      Align = alTop
      TabOrder = 3
      object lbl7: TLabel
        Left = 1
        Top = 1
        Width = 123
        Height = 13
        Align = alTop
        Caption = #20018#21475#21517#65306
        Layout = tlCenter
        ExplicitWidth = 48
      end
      object lbl8: TLabel
        Left = 1
        Top = 35
        Width = 123
        Height = 13
        Align = alTop
        Caption = #27874#29305#29575#65306
        Layout = tlCenter
        ExplicitWidth = 48
      end
      object lbl9: TLabel
        Left = 1
        Top = 69
        Width = 123
        Height = 13
        Align = alTop
        Caption = #25968#25454#20301#65306
        Layout = tlCenter
        ExplicitWidth = 48
      end
      object lbl4: TLabel
        Left = 1
        Top = 103
        Width = 123
        Height = 13
        Align = alTop
        Caption = #20572#27490#20301#65306
        Layout = tlCenter
        ExplicitWidth = 48
      end
      object lbl5: TLabel
        Left = 1
        Top = 137
        Width = 123
        Height = 13
        Align = alTop
        Caption = #22855#20598#26657#39564#20301#65306
        Layout = tlCenter
        ExplicitWidth = 72
      end
      object lbl6: TLabel
        Left = 1
        Top = 171
        Width = 123
        Height = 13
        Align = alTop
        Caption = #32531#23384#22823#23567#65306
        Layout = tlCenter
        ExplicitWidth = 60
      end
      object rzcbbComName: TRzComboBox
        Left = 1
        Top = 14
        Width = 123
        Height = 21
        Align = alTop
        Style = csDropDownList
        TabOrder = 0
      end
      object rzcbbBaudRate: TRzComboBox
        Left = 1
        Top = 48
        Width = 123
        Height = 21
        Align = alTop
        Style = csDropDownList
        TabOrder = 1
        Text = '9600'
        Items.Strings = (
          '300'
          '600'
          '1200'
          '2400'
          '4800'
          '9600'
          '19200'
          '38400'
          '43000'
          '56000'
          '57600'
          '115200')
        ItemIndex = 5
      end
      object rzcbbByteSize: TRzComboBox
        Left = 1
        Top = 82
        Width = 123
        Height = 21
        Align = alTop
        Style = csDropDownList
        TabOrder = 2
        Text = '8'
        Items.Strings = (
          '5'
          '6'
          '7'
          '8')
        ItemIndex = 3
      end
      object rzcbbStopBits: TRzComboBox
        Left = 1
        Top = 116
        Width = 123
        Height = 21
        Align = alTop
        Style = csDropDownList
        TabOrder = 3
        Text = '_1'
        Items.Strings = (
          '_1'
          '_1_5'
          '_2')
        ItemIndex = 0
      end
      object rzcbbParity: TRzComboBox
        Left = 1
        Top = 150
        Width = 123
        Height = 21
        Align = alTop
        Style = csDropDownList
        TabOrder = 4
        Text = 'None'
        Items.Strings = (
          'None'
          'Odd'
          'Even'
          'Mark'
          'Space')
        ItemIndex = 0
      end
      object rzcbbBuffSize: TRzComboBox
        Left = 1
        Top = 184
        Width = 123
        Height = 21
        Align = alTop
        Style = csDropDownList
        TabOrder = 5
        Text = '1024'
        Items.Strings = (
          '8'
          '16'
          '32'
          '64'
          '128'
          '256'
          '512'
          '1024'
          '2048'
          '4096')
        ItemIndex = 7
      end
    end
  end
  object grp7: TGroupBox
    Left = 217
    Top = 0
    Width = 256
    Height = 315
    Align = alLeft
    Caption = #28201#28287#24230#20256#24863#22120#37197#32622
    TabOrder = 2
    object pnl3: TPanel
      Left = 2
      Top = 15
      Width = 252
      Height = 26
      Align = alTop
      Caption = 'pnl1'
      TabOrder = 0
      object lbl3: TLabel
        Left = 1
        Top = 1
        Width = 60
        Height = 24
        Align = alLeft
        Caption = #27169#22359#36873#25321#65306
        Layout = tlCenter
        ExplicitHeight = 13
      end
      object cbbSensor: TComboBox
        Left = 61
        Top = 1
        Width = 93
        Height = 21
        Align = alClient
        TabOrder = 0
        Text = 'cbbModu'
        OnChange = cbbSensorChange
        Items.Strings = (
          #27169#22359'1'
          #27169#22359'2'
          #27169#22359'3'
          #27169#22359'4'
          #27169#22359'5'
          #27169#22359'6'
          #27169#22359'7'
          #27169#22359'8')
      end
      object btnSetCor: TBitBtn
        Left = 154
        Top = 1
        Width = 97
        Height = 24
        Align = alRight
        Caption = #20445#23384
        TabOrder = 1
        OnClick = btnSetCorClick
      end
    end
    object grp3: TGroupBox
      Left = 2
      Top = 161
      Width = 252
      Height = 152
      Align = alClient
      Caption = #26657#27491#25968#25454
      TabOrder = 1
      object strgrdCorrect: TStringGrid
        Left = 2
        Top = 15
        Width = 248
        Height = 135
        Align = alClient
        ColCount = 3
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
      end
    end
    object grp8: TGroupBox
      Left = 2
      Top = 41
      Width = 252
      Height = 120
      Align = alTop
      Caption = #20449#24687#25968#25454
      TabOrder = 2
      object strgrdSenAdd: TStringGrid
        Left = 2
        Top = 15
        Width = 248
        Height = 103
        Align = alClient
        ColCount = 3
        RowCount = 4
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        TabOrder = 0
      end
    end
  end
  object mscmCOM: TMSComm
    Left = 31
    Top = 234
    Width = 32
    Height = 32
    OnComm = mscmCOMComm
    ControlData = {
      2143341208000000ED030000ED03000001568A64000006000000010000040000
      00020000802500000000080000000000000000003F00000001000000}
  end
  object tmr1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmr1Timer
    Left = 72
    Top = 176
  end
  object idpsrvrMain: TIdUDPServer
    Bindings = <>
    DefaultPort = 0
    OnUDPRead = idpsrvrMainUDPRead
    Left = 128
    Top = 176
  end
end
