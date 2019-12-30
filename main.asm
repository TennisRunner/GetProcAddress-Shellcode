// FARPROC __stdcall GetProcAddress2(HMODULE hModule, DWORD dwNameSum)
GetProcAddress2:
push ebp
mov ebp, esp
sub esp, 0xC
push esi
 
// [ebp+C] = name sum
// [ebp+8] = module address
 
// [ebp-0x4] = export name table
// [ebp-0x8] = address of name ordinals
// [ebp-0xC] = address of functions
 
 
mov eax, [ebp+0x8]
mov	eax, dword ptr [eax+0x3C]	//to PE Header
add	eax, [ebp+0x8]
mov	eax, dword ptr [eax+0x78] 	//to export table
add	eax, [ebp+0x8]
mov	ecx, dword ptr [eax+0x24] 	//get the AddressOfNameOrdinals
mov [ebp-0x8], ecx
 
mov	ecx, dword ptr [eax+0x1C] 	//get the AddressOfFunctions
mov [ebp-0xC], ecx
 
mov	eax, dword ptr [eax+0x20] 	//to export name table
add	eax, [ebp+0x8]
mov [ebp-0x4], eax
 
mov ecx, -4
 
ProcLoop:
add ecx, 4
mov eax, [ebp-0x4] // mov into eax the export table
add eax, ecx       // add to eax the offset
mov eax, [eax]     // read the relative offset
add eax, [ebp+0x8] // add the module address
 
 
dec eax // prep string address
xor ebx, ebx // erase hash var
 
 
GetProcHashLoop:
inc eax
xor edx, edx
mov dl, byte ptr [eax]
add ebx, edx
cmp byte ptr [eax], 0
jne GetProcHashLoop
 
cmp ebx, [ebp+0xC] // compare it to the params
 
jne ProcLoop
mov esi, 2
xor edx, edx
mov eax, ecx
idiv esi // divide to get * 2
add eax, [ebp-0x8] // add it to the address of the ordinals
add eax, [ebp+0x8] // make it rva to virutal
xor edx, edx
mov dx, word ptr [eax]     // Read the oridinal
mov eax, edx               // pass the ordinal
imul eax, eax, 4           // Multiply it by 4
add eax, [ebp-0xC]         // add address of functions
add eax, [ebp+0x8]         // make it virtual
mov eax, [eax]             // read the function offset
add eax, [ebp+0x8]         // make it virtual
 
ExitProcLoop:
 
pop esi
mov esp, ebp
pop ebp
ret 8