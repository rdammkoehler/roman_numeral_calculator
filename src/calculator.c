#include "validate.h"
#include "convert_roman.h"
#include "adjust_roman.h"
#include "calculator.h"
#include <string.h>
#include <stdbool.h>

#define BUFFER_SIZE 100

static void set_error(char *str)
{
	strcpy(str, "ERROR");
}

void add(char *result, const char *left_oper, const char *right_oper)
{
	char left_operand[BUFFER_SIZE]; 
	char right_operand[BUFFER_SIZE];

	if (validate_inputs(left_oper, right_oper))
	{
		expand(left_operand, left_oper);
		expand(right_operand, right_oper);

		strcpy(result, left_operand);
		strcpy(&result[strlen(left_operand)], right_operand);

		contract(result);
		validate(result);
	} 
	else 
	{
		set_error(result);
	}
}

void subtract(char *result, const char *left_oper, const char *right_oper)
{
	char left_operand[BUFFER_SIZE];
	char right_operand[BUFFER_SIZE];

	if (validate_inputs(left_oper, right_oper))
	{
		expand(left_operand, left_oper);
		expand(right_operand, right_oper);
		do
		{
			while(0 != cancel_like_terms(left_operand, right_operand));
		}
		while(0 != expand_terms(left_operand, right_operand));
		strcpy(result, left_operand);
		contract(result);
		validate(result);
		if (0 < (int)strlen(right_operand))
		{
			set_error(result);
		}
	}
	else 
	{
		set_error(result);
	}
}
