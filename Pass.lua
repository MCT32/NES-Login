function addressWrite(address, value)
  if (value == 0xFF) then
    emu.log("passed!")
  end
end

emu.addMemoryCallback(addressWrite, emu.memCallbackType.cpuWrite, 0x000A)