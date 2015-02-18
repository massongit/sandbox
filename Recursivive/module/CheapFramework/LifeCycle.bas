Attribute VB_Name = "LifeCycle"
Option Explicit
'=============================================================================
' Constants
'=============================================================================
Private Const INJECT_PREFIX = "inject_"
'=============================================================================
' Win32API
'=============================================================================
Declare Function GetAsyncKeyState Lib "User32.dll" (ByVal vKey As Long) As Long

'=============================================================================
' SubProc
'=============================================================================

' OnStart -> �ċN���� -> OnEnd�̌Ăяo�����s���܂�
Public Sub ExecuteRecursive(ByVal dir As String)
    Dim res As Long
    If IsBlank(dir) = True Then
        MsgBox "�f�B���N�g�������͂���Ă��܂���", vbCritical
        Exit Sub
    End If
    res = (MsgBox(dir & "�z���̃t�@�C���Q���������܂�", vbYesNo))
    Call OnStart
    
    If res = vbYes Then
        Call FolderGrep(Cells(5, 2).MergeArea(1, 1).value)
    End If
    
    Call OnEnd
End Sub


' �ċN�����J�n���ɔ��s�����C�x���g
Private Sub OnStart()
    On Error Resume Next
    Call DebugLog("[FW]OnStart -> start")
    Call DebugLog("[FW]Invoke -> OnStart_" & Replace(Application.Caller, INJECT_PREFIX, ""))
    Application.Run ("OnStart_" & Replace(Application.Caller, INJECT_PREFIX, ""))
    Call DebugLog("[FW]OnStart -> end")
End Sub

' �ċN�����J�n���ɔ��s�����C�x���g
Private Sub OnEnd()
    On Error Resume Next
    Call DebugLog("[FW]OnEnd -> start")
    Call DebugLog("[FW]Invoke -> OnEnd_" & Replace(Application.Caller, INJECT_PREFIX, ""))
    Application.Run ("OnEnd_" & Replace(Application.Caller, INJECT_PREFIX, ""))
    Call DebugLog("[FW]OnEnd -> end")
End Sub


'=============================================================================
' Function
'=============================================================================


' ���t���N�V�����ɂ��DI���s���܂�
Public Function Inject(ByVal path As String, ByRef file As Object) As Boolean

    On Error GoTo ErrorHandler
    Call DebugLog("[FW]Inject -> start")
    Call DebugLog("[FW]Invoke ->" & Replace(Application.Caller, INJECT_PREFIX, ""))
    Inject = Application.Run(Replace(Application.Caller, INJECT_PREFIX, ""), path, file)
    Call DebugLog("[FW]Inject -> end")

ErrorHandler:
    If Err.Number <> 0 Then
        Call ErrorLog("[�G���[����]�F�G���[�R�[�h = " & Err.Number & vbNewLine & Err.Description)
        MsgBox "[�G���[����]�F�G���[�R�[�h = " & Err.Number & vbNewLine & Err.Description
    End If
End Function

' ���[�U�[�̏I���ʒm
Public Function IsUserEndCall(ByVal isEnd As Boolean) As Boolean
    Dim res As String
    If isEnd = True Then
        res = MsgBox("�I�����܂����H", vbYesNo)
        IsUserEndCall = (res = vbYes)
        Exit Function
    End If
    IsUserEndCall = False
End Function


