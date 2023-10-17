import pynvml

def get_gpu_info():
    pynvml.nvmlInit()
    device_count = pynvml.nvmlDeviceGetCount()

    gpu_info = []
    for i in range(device_count):
        handle = pynvml.nvmlDeviceGetHandleByIndex(i)

        gpu_name = pynvml.nvmlDeviceGetName(handle)
        gpu_memory_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
        gpu_memory_total = gpu_memory_info.total / 1024**2  # Convert to MB
        gpu_memory_used = gpu_memory_info.used / 1024**2  # Convert to MB

        gpu_info.append({
            "index": i,
            "name": gpu_name,
            "memory_total": gpu_memory_total,
            "memory_used": gpu_memory_used
        })

    pynvml.nvmlShutdown()
    return gpu_info

# Get GPU information
gpu_info = get_gpu_info()

# Print GPU information
for gpu in gpu_info:
    print(f"GPU {gpu['index']}: {gpu['name']}")
    print(f"Memory Total: {gpu['memory_total']} MB")
    print(f"Memory Used: {gpu['memory_used']} MB")
    print()