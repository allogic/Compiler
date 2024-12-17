#ifndef MACROS_H
#define MACROS_H

#ifndef MAX
	#define MAX(A, B) (((A) > (B)) ? (A) : (B))
#endif // MAX

#ifndef MIN
	#define MIN(A, B) (((A) < (B)) ? (A) : (B))
#endif // MIN

#ifndef UPDATE_CURSOR_LOCATION_SINGLE_LINE
	#define UPDATE_CURSOR_LOCATION_SINGLE_LINE() \
		yylloc.first_line = g_line_number; \
		yylloc.first_column = g_column_number; \
		g_column_number += yyleng; \
		yylloc.last_line = g_line_number; \
		yylloc.last_column = g_column_number - 1
#endif // UPDATE_CURSOR_LOCATION_SINGLE_LINE

#ifndef UPDATE_CURSOR_LOCATION_MULTI_LINE
	#define UPDATE_CURSOR_LOCATION_MULTI_LINE() \
		yylloc.first_line = g_line_number; \
		yylloc.first_column = g_column_number; \
		{ \
			char const* ptr = yytext; \
			while (*ptr) \
			{ \
				if (*ptr == '\r') \
				{ \
					g_column_number = 1; \
				} \
				else if (*ptr == '\n') \
				{ \
					g_line_number++; \
				} \
				else \
				{ \
					g_column_number++; \
				} \
				ptr++; \
			} \
		} \
		yylloc.last_line = g_line_number; \
		yylloc.last_column = g_column_number
#endif // UPDATE_CURSOR_LOCATION_MULTI_LINE

#ifndef UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN
	#define UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN() \
		yylloc.first_line = g_line_number; \
		yylloc.first_column = g_column_number; \
		g_column_number = 1; \
		yylloc.last_line = g_line_number; \
		yylloc.last_column = g_column_number
#endif // UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN

#ifndef UPDATE_CURSOR_LOCATION_NEW_LINE
	#define UPDATE_CURSOR_LOCATION_NEW_LINE() \
		yylloc.first_line = g_line_number; \
		yylloc.first_column = g_column_number; \
		g_line_number++; \
		yylloc.last_line = g_line_number; \
		yylloc.last_column = g_column_number
#endif // UPDATE_CURSOR_LOCATION_NEW_LINE

#ifndef STATIC_ASSERT
	#define STATIC_ASSERT(EXPRESSION, MESSAGE) typedef char const static_assertion_##MESSAGE[(EXPRESSION) ? 1 : -1]
#endif // STATIC_ASSERT

#endif // MACROS_H
