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
