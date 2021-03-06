function yn = is_text_tegion(cn);
    if (strcmp(cn,'text'));
        yn = true;
    elseif (strcmp(cn,'authour_list'));
        yn = false;
    elseif (strcmp(cn,'section_heading'));
        yn = true;
    elseif (strcmp(cn,'main_title'));
        yn = true;
    elseif (strcmp(cn,'decoration'));
        yn = false;
    elseif (strcmp(cn,'footnote'));
        yn = true;
    elseif (strcmp(cn,'abstract'));
        yn = true;
    elseif (strcmp(cn,'eq_number'));
        yn = false;
    elseif (strcmp(cn,'equation'));
        yn = false;
    elseif (strcmp(cn,'graph'));
        yn = false;
    elseif (strcmp(cn,'table'));
        yn = false;
    elseif (strcmp(cn,'table_caption'));
        yn = true;
    elseif (strcmp(cn,'figure_caption'));
        yn = true;
    elseif (strcmp(cn,'references'));
        yn = true;
    elseif (strcmp(cn,'subsection_heading'));
        yn = true;
    elseif (strcmp(cn,'image'));
        yn = false;
    elseif (strcmp(cn,'bullet_item'));
        yn = true;
    elseif (strcmp(cn,'code_block'));
        yn = false;
    elseif (strcmp(cn,'figure'));
        yn = false;
    elseif (strcmp(cn,'figure_label'));
        yn = true;
    elseif (strcmp(cn,'table_label'));
        yn = true;
    elseif (strcmp(cn,'header'));
        yn = false;
    elseif (strcmp(cn,'editor_list'));
        yn = true;
    elseif (strcmp(cn,'pg_number'));
        yn = false;
    elseif (strcmp(cn,'footer'));
        yn = false;
    elseif (strcmp(cn,'start_of_page'));
        yn = false;
    elseif (strcmp(cn,'end_of_page'));
        yn = false;
    else;
        yn = false;
    end;

