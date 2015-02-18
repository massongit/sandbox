Attribute VB_Name = "FileUtil"

Option Explicit

'=============================================================================
' Constants
'=============================================================================
Private Const INJECT_PREFIX = "inject_"

'=============================================================================
' Enum
'=============================================================================
' �u�c�[�����Q�Ɓv��Microsoft ActiveX Data Objects 6.1 Library���Q�Ƃ���ꍇ�͈ȉ���Enum�͕s�v
Public Enum StreamTypeEnum
  adTypeBinary = 1  '&H1
  adTypeText = 2  '&H2
End Enum

Public Enum StreamWriteEnum
  adWriteChar = 0  '&H0
  adWriteLine = 1  '&H1
  stWriteChar = 0  '&H0
  stWriteLine = 1  '&H1
End Enum

Public Enum SaveOptionsEnum
  adSaveCreateNotExist = 1  '&H1
  adSaveCreateOverWrite = 2  '&H2
End Enum

Public Enum StreamReadEnum
  adReadAll = -1  '&HFFFFFFFF
  adReadLine = -2  '&HFFFFFFFE
End Enum

'=============================================================================
' SubProc , Function
'=============================================================================
' �G�N�X�v���[���[�Ńf�B���N�g��������
Public Function DecideDirectory()
    Dim res As Long
    With Application.FileDialog(msoFileDialogFolderPicker)
        If .Show = True Then
            DecideDirectory = .SelectedItems(1)
        End If
    End With
End Function
' �N�_�ƂȂ�f�B���N�g�����牺�̊K�w���ċN�I�ɏ������܂�
Public Function FolderGrep(ByVal strTargetDir As String) As Boolean
    Dim fso As Object
    Dim folder As Object
    Dim subFolder As Object
    Dim file As Object
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set folder = fso.GetFolder(strTargetDir)
    ' �J�����g�t�H���_���̃��[�v
    For Each file In folder.Files
        If Inject(strTargetDir, file) = False Then
            MsgBox "�������s", vbCritical
            Exit Function
        End If
        If IsUserEndCall(GetAsyncKeyState(vbKeyControl) And GetAsyncKeyState(vbKeyC)) Then
            Exit Function
        End If
    Next file

    ' �T�u�t�H���_���̃��[�v
    For Each subFolder In folder.SubFolders
        ' �ċN�����Ăяo��
        Call FolderGrep(subFolder.path)
    Next subFolder

    ' �I�u�W�F�N�g���
    Set fso = Nothing
    Set folder = Nothing
End Function
' �e�L�X�g�t�@�C���̓ǂݍ���
' �f�t�H���g��UTF-8
Public Function LoadTextFile(ByVal fileName As String, Optional encode = "UTF-8") As String
    Dim stream As Object
    
    ' �t�@�C�����Ȃ��ꍇ�͋󕶎������^�[��
    If dir(fileName) = "" Then
        LoadTextFile = ""
        Exit Function
    End If
    
    Set stream = CreateObject("ADODB.Stream")
    With stream
        .Type = adTypeText
        .Charset = encode
        .Open
        .LoadFromFile (fileName)
        LoadTextFile = .ReadText(adReadAll)
        .Close
    End With
    
    Set stream = Nothing
End Function

' �e�L�X�g�̏o��
' �f�t�H���g��UTF-8
Public Sub OutputTextFile(ByVal text As String, ByVal fileName As String, Optional addMode, Optional encode = "UTF-8")
    On Error GoTo ErrorHandler
    Dim stream As Object
    ' �ǋL���[�h����
    text = IIf(IsMissing(addMode) = False, LoadTextFile(fileName, encode), "") & text
    ' ������
    Set stream = CreateObject("ADODB.Stream")
    With stream
        .Open
        .Type = adTypeText
        .Charset = encode
        .WriteText text, adWriteLine
        If UCase(encode) = "UTF-8" Then Call RemoveBOM(stream)
        .savetofile (fileName), adSaveCreateOverWrite
        .Close
    End With
    Set stream = Nothing
ErrorHandler:
    If Err.Number <> 0 Then
        Debug.Print ("[�G���[����]�F�G���[�R�[�h = " & Err.Number & vbNewLine & Err.Description)
        MsgBox "[�G���[����]�F�G���[�R�[�h = " & Err.Number & vbNewLine & Err.Description
    End If
    Set stream = Nothing
End Sub
' BOM���폜����
Private Sub RemoveBOM(ByRef stream As Object)
    Dim byteData() As Byte
    
    With stream
        .Position = 0
        .Type = adTypeBinary
        .Position = 3
        byteData = .read
        .Close
        .Open
        .write byteData
    End With
End Sub
