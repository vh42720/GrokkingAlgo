#!/usr/bin/env python3
"""
Interview Questions Practice Script

I. Python & SQL Fundamentals:
--------------------------------
1. Python Functions:
   - Explain the use and behavior of the zip() function.
   - What are f-strings in Python and how are they used?

2. SQL Scenario:
   - In the context of a video streaming platform (like Netflix), how would you update a daily aggregate table
     from a user activity fact table?

II. Video Streaming Platform Scenario (Python):
-----------------------------------------------
3. Mapping and Ranking:
   - Given a list of movies and their categories, write a Python function that maps movies to categories
     and returns the top 3 movies for each category.

III. Algorithm & Data Structure Problems:
-------------------------------------------
4. Smallest Odd Integer Formation:
   - Problem: Given an integer, return the smallest integer that can be formed using only its odd digits.
   - Example: For 1234, return 13.
   - Edge Cases: Negative numbers (e.g., -23) or cases where the input contains only even digits (e.g., 24 or 0)
     should return None.

5. Most Frequent Bookstore Comment:
   - Problem: Given a bookstore dataset (a dictionary), determine the most frequently mentioned comment.
   - Example:
         bookstore = {
             'nyc': ['perfect', 'perfect', 'brilliant', 'love it!'],
             'london': ['gorgeous', 'brilliant'],
             'berlin': ['awful']
         }
     If multiple comments tie for frequency, returning any one of them is acceptable.
   - Consideration: Remove duplicates if necessary.

6. Maximum Class Enrollments Over Consecutive Years:
   - Problem: Given a list of courses with enrollments and their time ranges, calculate the maximum number of class
     enrollments that occur over any two consecutive years.
   - Example:
         courses = [
             ('chemistry', 4, 2010, 2014),
             ('math', 2, 2008, 2012)
         ]
     Expected result: 12

7. Bookshelf Thickness Problem:
   - Problem: Determine how books of varying thickness can be arranged to fit onto a bookshelf with a given thickness.

8. Meeting Scheduling Problem:
   - Problem: In a classic meeting scheduling scenario, find the person who attended the most consecutive two-year sessions.
"""


def practice_python_functions():
	"""
	Practice Problem 1: Python Functions
	- Explain the use and behavior of the zip() function.
	- What are f-strings in Python and how are they used?
	"""
	# TODO: Provide your own examples and explanations for zip() and f-strings.
	pass


def practice_sql_scenario():
	"""
	Practice Problem 2: SQL Scenario
	- In the context of a video streaming platform, write an SQL statement to update a daily aggregate table
	  from a user activity fact table.
	"""
	# TODO: Write the SQL query and logic.
	pass


def practice_movie_mapping(movies: dict):
	"""
	Practice Problem 3: Mapping and Ranking Movies
	- Given a list of movies and categories, write a function that maps movies to categories and returns the top 3 movies per category.
	movies1 = [
		("Movie A", "Action", 8.2),
		("Movie B", "Comedy", 7.5),
		("Movie C", "Action", 9.0),
		("Movie D", "Action", 8.5),
		("Movie E", "Comedy", 8.1),
		("Movie F", "Action", 7.8),
		("Movie G", "Comedy", 7.3),
		("Movie H", "Drama", 8.9),
		("Movie I", "Drama", 8.2),
		("Movie J", "Drama", 8.6),
		("Movie K", "Drama", 7.9),
	]
	"""
	genre_movies = {}

	for movie in movies:
		title, genre, score = movie
		if genre not in genre_movies:
			genre_movies[genre] = []
		genre_movies[genre].append(movie)

	result = {}
	for genre, movie_list in genre_movies.items():
		sorted_movie = sorted(movie_list, key=lambda movie: movie[2], reverse=True)
		result[genre] = [i[0] for i in sorted_movie[:3]]

	return result


def smallest_odd_integer(num):
	"""
	Practice Problem 4: Smallest Odd Integer Formation
	Given an integer, return the smallest integer that can be formed using only its odd digits.
	Example: 1234 -> 13
	Edge Cases: Negative numbers (e.g., -23) or inputs with only even digits (e.g., 24 or 0) should return None.
	"""
	if num < 0:
		nums = abs(num)

	digits = list(str(num))
	odd_digits = [digit for digit in digits if int(digit) % 2 == 1]
	if not odd_digits:
		return -1

	odd_digits.sort()
	return int(''.join(odd_digits))


def most_frequent_comment(bookstore):
	"""
	Practice Problem 5: Most Frequent Bookstore Comment
	Given a bookstore dataset represented as a dictionary, determine the most frequently mentioned comment.
	Example:
		bookstore = {
			'nyc': ['perfect', 'perfect', 'brilliant', 'love it!'],
			'london': ['gorgeous', 'brilliant'],
			'berlin': ['awful']
		}
	If multiple comments tie for frequency, return any one of them.
	"""
	comment_dict = {}
	for store, comment_list in bookstore.items():
		for comment in comment_list:
			comment_dict[comment] = comment_dict.get(comment, 0) + 1
	max_val = max(comment_dict.values())

	return [comment for comment, freq in comment_dict.items() if freq == max_val], max_val


def max_class_enrollments(courses, K):
	"""
	Practice Problem 6: Maximum Class Enrollments Over Consecutive Years
	Given a list of courses with enrollments and their time ranges, calculate the maximum number of class enrollments
	over any two consecutive years.
	Example:
		courses = [
			('chemistry', 4, 2010, 2014),
			('math', 2, 2008, 2012)
		]
	Expected result: 12
	"""

	if not courses:
		return 0

	year_course = {}
	for course in courses:
		_, num, start, end = course
		for i in range(start, end + 1, 1):
			year_course[i] = year_course.get(i, 0) + num

	years = year_course.keys()
	start, end = min(years), max(years)
	timeline = [year_course.get(i, 0) for i in range(start, end + 1)]
	print(timeline)

	consecutive_sum = sum(timeline[:K])
	max_enrollments = consecutive_sum
	for i in range(K, len(timeline)):
		consecutive_sum += timeline[i] - timeline[i - K]
		max_enrollments = max(max_enrollments, consecutive_sum)

	return max_enrollments


def bookshelf_arrangement(books, shelves):
	"""
	Practice Problem 7: Bookshelf Thickness Problem
	Determine how books of varying thickness can be arranged to fit onto a bookshelf with a given thickness.
	'books' is a list of book thicknesses.
	'shelf_thickness' is the maximum total thickness that can fit on the shelf.
	"""
	books.sort()
	shelves.sort()

	shelf_index = 0
	for book in books:
		while book > shelves[shelf_index] and shelf_index < len(shelves):
			shelf_index += 1
		if shelf_index == len(shelves):
			return False
		shelf_index += 1
	return True


def most_meetings_attended(meetings):
	"""
	Practice Problem 8: Meeting Scheduling Problem
	Given a list of meeting attendance records, find the person who attended the most consecutive two-year sessions.
	'meetings' could be a list of tuples or another appropriate data structure.
	"""
	attendance = {}

	for meeting in meetings:
		person, year = meeting
		attendance.setdefault(person, []).append(year)

	def longest_consecutive(years):
		years_set = set(years)
		longest = 0
		for year in years_set:
			if year - 2 not in years_set:
				current_year = year
				current_streak = 1
				while current_year + 2 in years_set:
					current_year += 2
					longest = max(current_streak, longest)
		return longest

	best_person = None
	max_chain = 0
	for person, years in attendance.items():
		chain = longest_consecutive(years)
		if chain > max_chain:
			max_chain = chain
			best_person = person

	return best_person


if __name__ == "__main__":
	# -----------------------------------------------------------------------------------------------
	# Test case for movies:
	movies1 = [
		("Movie A", "Action", 8.2),
		("Movie B", "Comedy", 7.5),
		("Movie C", "Action", 9.0),
		("Movie D", "Action", 8.5),
		("Movie E", "Comedy", 8.1),
		("Movie F", "Action", 7.8),
		("Movie G", "Comedy", 7.3),
		("Movie H", "Drama", 8.9),
		("Movie I", "Drama", 8.2),
		("Movie J", "Drama", 8.6),
		("Movie K", "Drama", 7.9),
	]
	movies2 = []
	movies3 = [
		("Movie L", "Horror", 6.5),
		("Movie M", "Horror", 7.0)
	]
	movies4 = [
		("Movie N", "Sci-Fi", 8.0),
		("Movie O", "Sci-Fi", 7.5),
		("Movie P", "Sci-Fi", 8.3)
	]
	# print(practice_movie_mapping(movies1))
	# print(practice_movie_mapping(movies2))
	# print(practice_movie_mapping(movies3))
	# print(practice_movie_mapping(movies4))

	# -----------------------------------------------------------------------------------------------
	# Max enrollments
	test_cases = [
		{
			"description": "Prompt example: two courses overlapping for 2 consecutive years",
			"courses": [
				('chemistry', 4, 2010, 2014),
				('math', 2, 2008, 2012)
			],
			"K": 2,
			"expected": 12
		},
		{
			"description": "Single course over 2 consecutive years",
			"courses": [
				('biology', 5, 2011, 2013)
			],
			"K": 2,
			"expected": 10  # (5 + 5) over any two consecutive years in [2011, 2013]
		},
		{
			"description": "Non-overlapping courses",
			"courses": [
				('art', 3, 2000, 2002),
				('history', 4, 2005, 2007)
			],
			"K": 2,
			"expected": 8  # Only one course is active in any window (either 3+3 or 4+4)
		},
		{
			"description": "Multiple overlapping courses",
			"courses": [
				('physics', 2, 2001, 2005),
				('chemistry', 3, 2003, 2007),
				('math', 4, 2006, 2009)
			],
			"K": 2,
			"expected": 14  # Maximum over years 2006-2007: chemistry (3) + math (4) each year -> (7+7)
		},
		{
			"description": "Window size of 3 consecutive years",
			"courses": [
				('history', 3, 2000, 2003),
				('literature', 2, 2002, 2004)
			],
			"K": 3,
			"expected": 13  # Best window is 2001-2003: 2001: 3, 2002: (3+2)=5, 2003: (3+2)=5 => 3+5+5 = 13
		},
		{
			"description": "Empty courses list",
			"courses": [],
			"K": 2,
			"expected": 0
		},
		{
			"description": "All courses in one year with a window size of 1",
			"courses": [
				('A', 1, 2010, 2010),
				('B', 2, 2010, 2010),
				('C', 3, 2010, 2010)
			],
			"K": 1,
			"expected": 6  # Only year 2010: 1+2+3 = 6
		}
	]

	# for test in test_cases:
	# 	result = max_class_enrollments(test["courses"], test["K"])
	# 	print(f"{test['description']}: Expected {test['expected']}, Got {result}")

	# -----------------------------------------------------------------------------------------------
	# Example test for Practice Problem 4: Smallest Odd Integer Formation
	test_number = 1234
	# print("Smallest odd integer formed from", test_number, ":", smallest_odd_integer(test_number))

	# -----------------------------------------------------------------------------------------------
	# Example test for Practice Problem 5: Most Frequent Bookstore Comment
	bookstore = {
		'nyc': ['perfect', 'perfect', 'brilliant', 'love it!'],
		'london': ['gorgeous', 'brilliant'],
		'berlin': ['awful']
	}
	# print("Most frequent comment in bookstore:", most_frequent_comment(bookstore))

	# -----------------------------------------------------------------------------------------------
	# Example of Bookshelf arrangement
	# Test case 1: Single book that can fit into available shelf compartments.
	books1 = [1]
	shelf_thickness1 = [2, 3]  # More compartments than books.
	# print("Test case 1 (expect True):", bookshelf_arrangement(books1, shelf_thickness1))

	# Test case 2: Multiple books that exceed the available compartments.
	books2 = [1, 2, 3]
	shelf_thickness2 = [2, 4, 5]
	# print("Test case 2 (expect True):", bookshelf_arrangement(books2, shelf_thickness2))

	# Test case 3: No books to arrange, so arrangement trivially works.
	books3 = []
	shelf_thickness3 = [2, 4, 5]
	# print("Test case 3 (expect True):", bookshelf_arrangement(books3, shelf_thickness3))

	# -----------------------------------------------------------------------------------------------
	# Test Case 1: Clear winner.
	# Alice attends sessions in 2000, 2002, and 2004 (3 consecutive sessions),
	# Bob attends sessions in 2000 and 2002 (2 consecutive sessions),
	# Charlie attends sessions in 2000, 2002, 2004, and 2006 (4 consecutive sessions).
	meetings1 = [
		("Alice", 2000),
		("Alice", 2002),
		("Alice", 2004),
		("Bob", 2000),
		("Bob", 2002),
		("Charlie", 2000),
		("Charlie", 2002),
		("Charlie", 2004),
		("Charlie", 2006),
	]
	# Expected output: "Charlie"

	# Test Case 2: Tie scenario.
	# Both Alice and Bob attend sessions in 2000 and 2002 (each has a chain of 2).
	meetings2 = [
		("Alice", 2000),
		("Alice", 2002),
		("Bob", 2000),
		("Bob", 2002),
	]
# Expected output: Either "Alice" or "Bob" is acceptable.

print("Test Case 1 - Most meetings attended:", most_meetings_attended(meetings1))
print("Test Case 2 - Most meetings attended:", most_meetings_attended(meetings2))
