"""Process a stream of input data (list of dictionaries), checking conditions, buffering output, and handling edge cases"""


def flush_buffer(buffer, results):
	"""
	Flushes the current buffer.
	For demonstration, we print the buffer and add its contents to results.
	In a real scenario, this could be writing to a file or database.
	"""
	print("Flushing buffer:", buffer)
	results.extend(buffer)
	buffer.clear()


def process_stream(data_stream, buffer_limit=5):
	"""
	Process a stream of dictionaries by checking conditions,
	buffering processed outputs, and handling edge cases.

	Parameters:
		data_stream (list): A list of dictionaries to process.
		buffer_limit (int): The maximum number of processed items to hold before flushing.

	Returns:
		list: A list of all processed results.
	"""
	buffer = []
	results = []

	for index, item in enumerate(data_stream):
		try:
			# Validate that the item is a dictionary.
			if not isinstance(item, dict):
				print(f"Skipping item at index {index}: Not a dictionary -> {item}")
				continue

			# Check if the required key 'value' exists.
			if 'value' not in item:
				print(f"Skipping dictionary at index {index}: Missing 'value' key -> {item}")
				continue

			value = item['value']

			# Ensure the value is numeric.
			if not isinstance(value, (int, float)):
				print(f"Skipping dictionary at index {index}: 'value' is not numeric -> {item}")
				continue

			# Example condition: process only non-negative values.
			if value < 0:
				print(f"Skipping dictionary at index {index}: Negative value encountered -> {value}")
				continue

			# Process the item (for example, double the 'value').
			processed_result = value
			buffer.append(processed_result)

			# When the buffer reaches the defined limit, print and flush it.
			if len(buffer) == buffer_limit:
				print("Buffer reached limit of 3:", buffer)
				flush_buffer(buffer, results)

		except Exception as e:
			print(f"Error processing item at index {index} -> {item}: {e}")

	# Flush any remaining items in the buffer.
	if buffer:
		flush_buffer(buffer, results)

	return results


# Example usage:
if __name__ == "__main__":
	# Example stream of input data
	data_stream = [
		{"value": 10},
		{"value": 5},
		{"value": -3},  # This will be skipped (negative value)
		{"value": "abc"},  # This will be skipped (non-numeric)
		{"other_key": 20},  # This will be skipped (missing 'value')
		"not a dict",  # This will be skipped (not a dict)
		{"value": 7},
		{"value": 3}
	]

	processed_results = process_stream(data_stream, buffer_limit=3)
	print("Final processed results:", processed_results)
