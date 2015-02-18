Attribute VB_Name = "Logic"
'=============================================================================
' Fields
'=============================================================================
Option Explicit

' �N���b�N���̃A�N�V�����B�{�^���͑S�Ă��̃v���V�[�W�������s�����ėǂ�
Public Sub ClickAction()
    MsgBox "�������J�n���܂�"
    SetLogFilePath ("C:\hoge\test.log")
    SetLogLevel (1)
    Call ExecuteRecursive(Cells(5, 2).MergeArea(1, 1).value)
    MsgBox "�������I�����܂���"
End Sub
' �悭����G�N�X�v���[���ɂ��f�B���N�g���I��(�T���v���j
Public Sub ChooseDir()
    If IsNotBlank(DecideDirectory) Then
        Cells(5, 2).MergeArea(1, 1).value
    End If
End Sub
' �悭���鏈���BA1�Z���őS���u�b�N��ۑ�(�T���v���j
Public Function SaveAtFirstInBook(ByVal path As String, ByRef file As Object) As Boolean
    Dim i As Long
    With file
        Call DebugLog(.Name)
        If InStr(.Name, ".xls") <> 0 Then
            Workbooks.Open path + Application.PathSeparator + .Name
            For i = Workbooks(.Name).Worksheets.Count To 1 Step -1
                Workbooks(.Name).Worksheets(i).Activate
                Cells(1, 1).Select
            Next i
            Workbooks(.Name).Save
            Workbooks(.Name).Close
        End If
    End With
    SaveAtFirstInBook = True
End Function
' �悭����f�[�^�̒��o�ƌ��ʏo�́i�T���v���j
Public Function ExportBookData(ByVal path As String, ByRef file As Object) As Boolean
    Dim cellStr As String
    Dim cellCnt As String

    With file
        If InStr(.Name, ".xls") <> 0 Then
            Workbooks.Open path + Application.PathSeparator + .Name
            cellStr = Workbooks(.Name).Worksheets(1).Cells(1, 1).value
            Workbooks(.Name).Close
            Workbooks(Workbooks.Item(Workbooks.Count()).Name).Activate
            cellCnt = 1
            Do While Len(Trim(Cells(cellCnt, 2).value)) <> 0
                cellCnt = cellCnt + 1
            Loop
            
            Cells(cellCnt, 1).value = cellStr
            Cells(cellCnt, 2).value = .Name
        End If
    End With
    ExportBookData = True
End Function
' AOP�̃��C�t�T�C�N���v���V�[�W���i����Ă����Ȃ��Ă��ǂ��j
Public Sub OnStart_ExportBookData()
    Dim orgBookName As String
    Dim targetSheet As Worksheet
    orgBookName = ActiveWorkbook.Name
    Application.DisplayAlerts = False
    Workbooks.Add
    Set targetSheet = Workbooks(Workbooks.Item(Workbooks.Count()).Name).Worksheets(1)
    targetSheet.Range("A1").value = "A1�̒l"
    targetSheet.Range("B1").value = "�t�@�C����"
    targetSheet.Range("A1:B1").Select
    Selection.Font.Bold = True
    With Selection.Interior
        .Pattern = xlSolid
        .Color = 65535
    End With
    Workbooks(orgBookName).Activate
    Call DebugLog("OnStart_ExportBookData called")
End Sub
' AOP�̃��C�t�T�C�N���v���V�[�W���i����Ă����Ȃ��Ă��ǂ��j
Public Sub OnEnd_ExportBookData()
    Application.DisplayAlerts = True
    Call DebugLog("OnEnd_ExportBookData called")
End Sub
' AOP�̃��C�t�T�C�N���v���V�[�W���i����Ă����Ȃ��Ă��ǂ��j
Public Sub OnStart_SaveAtFirstInBook()
    Application.DisplayAlerts = False
    Call DebugLog("OnStart_SaveAtFirstInBook called")
End Sub
' AOP�̃��C�t�T�C�N���v���V�[�W���i����Ă����Ȃ��Ă��ǂ��j
Public Sub OnEnd_SaveAtFirstInBook()
    Application.DisplayAlerts = True
    Call DebugLog("OnEnd_SaveAtFirstInBook called")
End Sub