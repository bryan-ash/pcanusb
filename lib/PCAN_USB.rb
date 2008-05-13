=begin
  This class is a wrapper for the PCAN USB DLL
=end

require "dl"
require "dl/import"
require "dl/struct"

class PCAN_USB

  # BAUD rates used by "init"
  BAUD_1M   = 0x0014
  BAUD_500K = 0x001C
  BAUD_250K = 0x011C
  BAUD_125K = 0x031C
  BAUD_100K = 0x432F
  BAUD_50K  = 0x472F
  BAUD_20K  = 0x532F
  BAUD_10K  = 0x672F
  BAUD_5K   = 0x7F7F

  # used by "init" and "set_receive_filter"
  CAN_INIT_TYPE_ST = 0  # 11 Bit-ID handling - Standard frame
  CAN_INIT_TYPE_EX = 1  # 29 Bit ID handling - Extended frame

  # used by "write" and "read"
  MSGTYPE_STANDARD = 0x00
  MSGTYPE_RTR      = 0x01
  MSGTYPE_EXTENDED = 0x02
  MSGTYPE_STATUS   = 0x80

  # return values
  CAN_OK             = 0x0000  # No error.
  CAN_XMTFULL        = 0x0001  # Transmission buffer of the controller is full.
  CAN_OVERRUN        = 0x0002  # CAN controller has been read out too late.
  CAN_BUSLIGHT       = 0x0004  # Bus error: An error counter has reached the 'Light' limit.
  CAN_BUSHEAVY       = 0x0008  # Bus error: An error counter has reached the 'Heavy' limit.
  CAN_BUSOFF         = 0x0010  # Bus error:Actual state from the CAN controller is 'Bus Off'.
  CAN_QRCVEMPTY      = 0x0020  # Receive queue is empty.
  CAN_QOVERRUN       = 0x0040  # Receive queue has been read out too late.
  CAN_QXMTFULL       = 0x0080  # Transmission queue is full.
  CAN_REGTEST        = 0x0100  # Register test of the 82C200/SJA1000 has failed.
  CAN_NOVXD          = 0x0200  # Driver is not loaded.
  CAN_ILLHW          = 0x1400  # Hardware handle is invalid.
  CAN_ILLNET         = 0x1800  # Net handle is invalid.
  CAN_MASK_ILLHANDLE = 0x1C00  # Mask for all handle errors.
  CAN_ILLCLIENT      = 0x1C00  # Client handle is invalid.
  CAN_RESOURCE       = 0x2000  # Resource (FIFO, client, timeout) cannot be created.
  CAN_ILLPARAMTYPE   = 0x4000  # Parameter is not permitted/applicable here.
  CAN_ILLPARAMVAL    = 0x8000  # Parameter value is invalid.

  def self.init(baud_value, message_type = CAN_INIT_TYPE_EX)
    err = Core::cAN_Init(baud_value, message_type)
    
    # allow the hardware to initialize
    sleep 0.125
    
    return err
  end

  def self.close
    return Core::cAN_Close
  end
  
  def self.status
    return Core::cAN_Status
  end
  
  def self.write(id, data, message_type = MSGTYPE_EXTENDED)
    message = Core::TPCANMsg.malloc
    message.id = id
    message.message_type = message_type
    message.length = data.length
    message.data = data.dup
    
    return Core::cAN_Write(message)
  end
  
  # Set the range of message ID that will be accepted.
  # CAN_ResetFilter is used first to close the filter range,
  # then CAN_MsgFilter is used to open it up.
  def self.set_receive_filter(fromID, toID, message_type = MSGTYPE_EXTENDED)
    Core::cAN_ResetFilter
    return Core::cAN_MsgFilter(fromID, toID, message_type)
  end
  
  def self.read
    message = Core::TPCANMsg.malloc
    
    err = Core::cAN_Read(message)
    
    return err, message.message_type, message.id, message.data[0..message.length - 1]
  end

  def self.read_id(id, timeout=1)
    read_timeout = Time.now + timeout
  
    begin
      err, rx_type, rx_id, rx_data = self.read

      if err == CAN_OK && rx_id == id then
        return rx_data
      end
    end while Time.now < read_timeout
    
    return false
  end
  
  def self.reset_client
    return Core::cAN_ResetClient
  end

  def self.version_info
    info = Core::Version_Info.malloc
    
    err = Core::cAN_VersionInfo(info)

    # info.value is an array of characters, convert it to string 
    return info.value.pack("c128")
  end
  
  def self.get_usb_device_number
    number = Core::Device_Number.malloc
    
    err = Core::getUSBDeviceNr(number)
    
    return err, number.value
  end
  
  module Core
    extend DL::Importable
    
    dlload File.dirname(__FILE__) + "/Pcan_usb.dll"
    
    TPCANMsg = struct [
      "long id",
      "char message_type",
      "char length",
      "UCHAR data[8]",
    ]
   
    Device_Number = struct ["long value"]
    Version_Info  = struct ["char value[128]"]
    
    extern "long CAN_Init(long, int)"  
    extern "long CAN_Close()"
    extern "long CAN_Status()"  
    extern "long CAN_Write(TPCANMsg *)"  
    extern "long CAN_Read(TPCANMsg *)"  
    extern "long CAN_VersionInfo(Version_Info *)"  
    extern "long CAN_ResetClient()"  
    extern "long CAN_MsgFilter(DWORD, DWORD, int)"  
    extern "long CAN_ResetFilter()"  
    extern "long SetUSBDeviceNr(long)"  
    extern "long GetUSBDeviceNr(long *)"  
  end # module Core
  
end # class PCAN_USB
