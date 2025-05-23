#' Add nodes
#'
#' Create/add vertically aligned labeled nodes or side nodes.
#'
#'
#' @param prev_box Previous node object, the created new node will be vertically
#' aligned with this node. Left this as `NULL` if this is the first node. The first
#' node will be aligned in the top center.
#' @param txt Text in the node. If the `prev_box` is a horizontally aligned multiple
#' nodes, a vector of with the same length must be provided.
#' @param just The justification for the text: left, center or right.
#' @param text_width a positive integer giving the target column for wrapping
#' lines in the output. String will not be wrapped if not defined (default).
#' The \code{\link[stringi]{stri_wrap}} function will be used if \code{stringi}
#' package installed as it is a better options for non-Latin language, otherwise
#'  \code{\link[base]{strwrap}} will be used.
#' @param ... Other parameters pass to \link{textbox},
#'
#' @seealso \code{\link{add_side_box}} \code{\link{add_split}} \code{\link{textbox}} 
#' \code{\link{add_label_box}}
#' @return A \code{consort} object.
#'
#' @export
#'
#' @example inst/examples/add-box-example.R
add_box <- function(prev_box = NULL,
                    txt,
                    just = c("center", "left", "right"),
                    text_width = NULL,
                    ...) {

  dots <- list(...)
  if("name" %in% names(dots)){
    warning("`parameter name was provided but will be ignored.")
    dots$name <- NULL
  }

  # Update arguments
  args_list <- list(box_fn = rectGrob, just = just, name = "vertbox")
  args_list <- modifyList(args_list, dots)

  just <- match.arg(just)
  
  # Wrap text
  if (!is.null(text_width)) {
    txt <- sapply(txt, function(tx) {
      text_wrap(unlist(tx), width = text_width)
    })
  }

  if (!is.null(prev_box)) {
    if (!inherits(prev_box, c("consort"))) {
      stop("prev_box must be consort object")
    }

    if(attr(prev_box, "nodes.type") == "label")
      stop("The last box added is a label, can not add box after a label!")

    prev_nodes <- attr(prev_box, "nodes.current")
    num_nodes <- attr(prev_box, "nodes.num")

    if (length(txt) != 1 & !length(prev_nodes) %in% c(1, length(txt))) {
      stop("Text with length of 1 or same node number as `prev_box`.")
    }

    if(length(prev_nodes) != length(txt))
      prev_nodes <- rep(prev_nodes, length(txt))

    # Create node
    nodes <- lapply(seq_along(txt), function(i){
      box <- do.call(textbox, c(list(text = txt[i]), args_list))
      if(length(txt) == 1){
        prev_nd <- prev_nodes
      }else{
        prev_nd <- prev_nodes[i]
      }

      if(length(txt) == length(prev_nodes) && is_empty(prev_box[[prev_nd]]$text))
        prev_nd <- prev_box[[prev_nd]]$prev_node
        

      list(
        text = txt[i],
        node_type = "vertbox",
        box = box,
        box_hw = get_coords(box),
        just = just,
        side = NULL,
        prev_node = prev_nd
      )
    })

    names(nodes) <- paste0("node", num_nodes + seq_along(txt))

    node_list <- c(prev_box, nodes)

    class(node_list) <- union("consort", class(node_list))

    structure(node_list,
      nodes.num = length(txt) + num_nodes,
      nodes.current = names(nodes),
      nodes.type = "vertbox",
      nodes.list = c(attr(prev_box, "nodes.list"), list(names(nodes)))
    )

  } else {

    nodes <- lapply(txt, function(x){
      box <- do.call(textbox, c(list(text = x), args_list))
      list(
        text = x,
        node_type = "vertbox",
        box = box,
        box_hw = get_coords(box),
        side = NULL,
        just = just,
        inv_join = NULL,
        prev_node = NULL
      )
    })

    names(nodes) <- paste0("node", seq_along(txt))

    class(nodes) <- union("consort", class(nodes))

    structure(nodes,
      nodes.num = length(txt),
      nodes.current = names(nodes),
      nodes.type = "vertbox",
      nodes.list = list(names(nodes))
    )

  }
}

