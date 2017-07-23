# 添加包含路径
vpath %.S stlib
vpath %.c stlib stlib/src 
vpath %.h stlib stlib/cminc stlib/inc

DEFS += -DUSE_STDPERIPH_DRIVER

INCS += -Istlib -Istlib/cminc -Istlib/inc

# 使用其他外设在这里添加
OBJS += main.o
OBJS += stlib/startup_stm32f40xx.o 
OBJS += stlib/system_stm32f4xx.o
OBJS += stlib/src/stm32f4xx_rcc.o stlib/src/stm32f4xx_gpio.o 

# 使用了编译优化和硬件浮点数
CFLAGS += -mcpu=cortex-m4 -mthumb -Wall 
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -Os
CFLAGS += -ffunction-sections -fdata-sections

LFLAGS += -mcpu=cortex-m4 -mthumb
LFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LFLAGS += -Wl,--gc-sections 

# 最后生成的bin文件
all:blink.bin

clean:
	@rm -f $(OBJS) $(OBJ_FLASH) $(OBJ_SRAM)  
	@rm -f blink.bin blink.elf blinks.bin blinks.elf
    
blink.bin:blink.elf
	@arm-none-eabi-objcopy -O binary -S $< $@
blinks.bin:blinks.elf
	@arm-none-eabi-objcopy -O binary -S $< $@
    
blink.elf:$(OBJS) $(OBJ_FLASH)
	@arm-none-eabi-gcc $(LFLAGS) $^ -Tstlib/STM32F407ZET6_FLASH.ld -o $@
	@arm-none-eabi-size $@
    
burn:blink.bin
	@st-flash write $< 0x08000000
    
%.o:%.S
	@echo cc: $<
	@arm-none-eabi-gcc $(CFLAGS) -c $< -o $@
%.o:%.c
	@echo cc: $<
	@arm-none-eabi-gcc $(CFLAGS) $(DEFS) $(INCS) -c $< -o $@
