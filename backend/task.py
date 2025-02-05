# tasks.py
def example_task(x, y):
    try:
        print(f"Executing example_task with arguments: {x}, {y}")
        result = x + y
        print(f"Task result: {result}")
        return result
    except Exception as e:
        print(f"Task failed with error: {e}")
        raise